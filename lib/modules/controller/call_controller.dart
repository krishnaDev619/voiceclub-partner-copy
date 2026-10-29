import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/rating_service.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_stat_label_widget.dart';

class CallController extends GetxController {
  final incomingCallPayload = ''.obs;
  final incomingGameCallPayload = ''.obs;
  final testPayloadReceived = false.obs;
  final isOutgoingCallActive = false.obs;
  final handleInvalidCallState = false.obs;

  bool get isOnCall =>
      incomingCallPayload.value.isNotEmpty || isOutgoingCallActive.value;

  void updateDetails(String data) {
    incomingCallPayload.value = data;
    update();
  }

  void updateGameDetails(String data) {
    incomingGameCallPayload.value = data;
    update();
  }

  void updateTestPayload() {
    testPayloadReceived.value = true;
  }

  void clearTestPayload() {
    testPayloadReceived.value = false;
    AwesomeNotifications().cancelNotificationsByChannelKey("1");
  }

  void endOutgoingCall() {
    isOutgoingCallActive.value = false;
    Get.find<UserController>().endIdleTimer();
    Get.find<UserController>().startIdleTimer();
  }

  void startOutgoingCall() {
    isOutgoingCallActive.value = true;
  }

  void setHandleInvalidCallState(bool value) {
    if (value == false) {
      incomingCallPayload.value = '';
    }
    handleInvalidCallState.value = value;
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  void endCall(
    int? demandAccountId,
    String name,
    int callDuration,
    CategoryCode category,
    bool isNewUser, {
    bool isFree = false,
    bool closeNewUserMenu = false,
  }) {
    try {
      Get.find<UserController>().fetchData();
      if (category == CategoryCode.GOSSIP) {
        Future.delayed(const Duration(seconds: 1), () async {
          if (!Get.isRegistered<ChatOverviewController>()) {
            return;
          }

          await Get.find<ChatOverviewController>().fetchPendingAudios();
        });
      }
      Future.delayed(const Duration(seconds: 65), (() {
        Get.find<UserController>().fetchData();
      }));
      incomingCallPayload.value = '';
      if (Get.currentRoute != '/IncomingCallScreen') {
        Get.until((route) => route.settings.name == '/IncomingCallScreen');
      }
      if (closeNewUserMenu) {
        closeUserInfoPopupMenuIfOpen();
      }
      Get.back(closeOverlays: true);
      update();
      if (isNewUser && demandAccountId != null && callDuration > 0) {
        Get.until((route) => route.isFirst);
        if (Get.isRegistered<ChatOverviewController>()) {
          Get.find<ChatOverviewController>().navigateToChatScreenUsingAccountId(
            peerAccountId: demandAccountId,
            isNew: true,
            screenName: "NewUserCall",
          );
        }
      }
      Get.find<UserController>().endIdleTimer();
      Get.find<UserController>().startIdleTimer();
      if (!isFree) {
        // If call has been accepted and the callDuration was more than 180 seconds
        if (demandAccountId != null && callDuration > 180) {
          RatingService.addSupplyRating(
            demandAccountId,
            name,
            AvatarService.getRandomAvatarUrl(),
            formatTime(callDuration),
            Get.context!,
            false,
            category.name,
          );
        }
      }
    } catch (e) {
      Logger.logMessage("Error in end call ${e.toString()}", isCritical: true);
    }
  }

  void endGameCall() {
    try {
      Get.find<UserController>().fetchData();
      Future.delayed(const Duration(seconds: 10), () {
        if (Get.isRegistered<ChatOverviewController>()) {
          Get.find<ChatOverviewController>().fetchPendingAudios();
        }
      });
      Future.delayed(const Duration(seconds: 65), (() {
        Get.find<UserController>().fetchData();
      }));
      incomingGameCallPayload.value = '';
      if (Get.currentRoute != '/IncomingGameCallScreen') {
        Get.until((route) => route.settings.name == '/IncomingGameCallScreen');
      }
      Get.back(closeOverlays: true);
      update();
      Get.find<UserController>().endIdleTimer();
      Get.find<UserController>().startIdleTimer();
    } catch (e) {
      Logger.logMessage(
        "Error in end game call ${e.toString()}",
        isCritical: true,
      );
    }
  }
}
