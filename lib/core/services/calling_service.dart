import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/reverse_call_service.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/domain/usecases/calling/place_call.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/auth/widgets/cancel_alert.dart';
import 'package:voiceclub_partner/view/calling/outgoing_call_screen.dart';

class CallingService {
  Future<bool> call({
    required UserDataModel demandUser,
    required int demandAccountId,
    required String screenName,
    int? chatGroupId,
  }) async {
    final demandUid = demandUser.id ?? 0;
    final demandName = demandUser.name ?? '';
    final demandPhoneNumber = demandUser.phoneNumber ?? '';
    final demandAvatar = demandUser.avatar;

    if (await Permission.microphone.isGranted) {
      return await _checkReverseCallAttempts(
        demandUid: demandUid,
        demandAccountId: demandAccountId,
        demandName: demandName,
        demandPhoneNumber: demandPhoneNumber,
        demandAvatar: demandAvatar,
        screenName: screenName,
        chatGroupId: chatGroupId,
      );
    } else {
      Permission.microphone.request().then((status) async {
        if (status == PermissionStatus.granted) {
          return await _checkReverseCallAttempts(
            demandUid: demandUid,
            demandAccountId: demandAccountId,
            demandName: demandName,
            demandPhoneNumber: demandPhoneNumber,
            demandAvatar: demandAvatar,
            screenName: screenName,
            chatGroupId: chatGroupId,
          );
        } else {
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Error,
            title: "Permission Denied",
            subtitle:
                "Please${status == PermissionStatus.permanentlyDenied ? " open settings and" : ""} give microphone access!",
          );
        }
      });
    }
    return false;
  }

  Future<bool> _checkReverseCallAttempts({
    required int demandUid,
    required int demandAccountId,
    required String demandName,
    required String demandPhoneNumber,
    required String? demandAvatar,
    required String screenName,
    int? chatGroupId,
  }) async {
    bool result = false;
    final failedCalls = await ReverseCallService.getFailedCalls(
      demandAccountId,
    );
    const maxAttempts = 2;
    if (failedCalls >= maxAttempts) {
      result =
          await Get.dialog<bool?>(
            CancelAlertDialog(
              title: "User Busy!",
              subtitle:
                  "You have tried $failedCalls times to call $demandName. Try again?",
            ),
          ) ??
          false;
    } else {
      result = true;
    }
    if (result) {
      return await _place(
        demandUid: demandUid,
        demandAccountId: demandAccountId,
        demandName: demandName,
        demandPhoneNumber: demandPhoneNumber,
        demandAvatar: demandAvatar,
        screenName: screenName,
        chatGroupId: chatGroupId,
      );
    }
    return false;
  }

  Future<bool> _place({
    required int demandUid,
    required int demandAccountId,
    required String demandName,
    required String demandPhoneNumber,
    required String? demandAvatar,
    required String screenName,
    int? chatGroupId,
  }) async {
    try {
      Get.context?.loaderOverlay.show();
      final response = await sl<PlaceCallUsecase>().call(
        Params(demandUid: demandUid),
      );
      if (response.data != null && response.error == null) {
        final dsValue = response.data!;
        String token = dsValue.token ?? '';
        String channelId = dsValue.channelId ?? '';
        sl<AnalyticsService>().trackEvent(
          "reverseCallInitiated",
          eventProperties: {
            "demandName": demandName,
            "demandNumber": demandPhoneNumber,
            "demandUid": demandUid,
            "demandAccountId": demandAccountId,
            "screenName": screenName,
            if (oneScore != null) "oneScore": oneScore,
            if (stage != null) "stage": stage,
          },
        );

        Get.context?.loaderOverlay.hide();
        Get.to(
          () => OutgoingCallScreen(
            channelId: channelId,
            token: token,
            demandUid: demandUid,
            demandAccountId: demandAccountId,
            demandName: demandName,
            demandPhoneNumber: demandPhoneNumber,
            demandAvatar: demandAvatar,
            screenName: screenName,
            chatGroupId: chatGroupId,
          ),
        );
        return true;
      } else if (response.error != null) {
        final e = response.error!;
        _handleCallError(
          e: e,
          demandUid: demandUid,
          demandAccountId: demandAccountId,
          demandName: demandName,
          demandPhoneNumber: demandPhoneNumber,
          demandAvatar: demandAvatar,
          screenName: screenName,
        );
      }
    } on DioException catch (e) {
      _handleCallError(
        e: e,
        demandUid: demandUid,
        demandAccountId: demandAccountId,
        demandName: demandName,
        demandPhoneNumber: demandPhoneNumber,
        demandAvatar: demandAvatar,
        screenName: screenName,
      );
    } finally {
      Get.context?.loaderOverlay.hide();
    }
    return false;
  }

  void _handleCallError({
    required DioException e,
    required int demandUid,
    required int demandAccountId,
    required String demandName,
    required String demandPhoneNumber,
    required String? demandAvatar,
    required String screenName,
  }) {
    Get.context?.loaderOverlay.hide();
    String title = "Something went wrong";
    String message = "Please try again later";
    try {
      final data = e.response?.data;
      title = data?['snackbar_title'] ?? 'Something went wrong';
      message =
          data?['snackbar_message'] ??
          data?['message'] ??
          "Please try again later";
    } catch (_) {
    } finally {
      final userController = Get.find<UserController>();
      sl<AnalyticsService>().trackEvent(
        "reverseCallFailed",
        eventProperties: {
          "demandName": demandName,
          "demandNumber": demandPhoneNumber,
          "demandUid": demandUid,
          "demandAccountId": demandAccountId,
          "screenName": screenName,
          "error": e.response?.data,
          "reason": title,
          "message": message,
          "ringState": RingState.CALLING.name,
          "ringDurationInSeconds": 0,
          "newUserCallLimitEnabled":
              userController.userDetails.value.showCallCount,
          if (userController.partnerStatus.value != PartnerCurrentStatus.NULL)
            "partnerStatus": userController.partnerStatus.value.name,
          if (oneScore != null) "oneScore": oneScore,
          if (stage != null) "stage": stage,
        },
      );

      // Show busy state for new user
      Vibration.vibrate();
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: title,
        subtitle: message,
      );
    }
  }

  num? get oneScore {
    try {
      return Get.find<ProbationController>().metricsData.value.aggregate?.score;
    } catch (_) {}
    return null;
  }

  String? get stage {
    try {
      return Get.find<UserController>().userDetails.value.onboardingStage?.name;
    } catch (_) {}
    return null;
  }
}
