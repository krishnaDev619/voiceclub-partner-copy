import 'dart:io';

import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voiceclub_partner/core/constants/enums.dart' show SnackBarType;
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/verify_gender/upload_file_response_model.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/liveness/check_liveness_hyperverge.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/liveness/check_liveness_idto.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/upload_file/upload_onboarding_file.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/verify_gender/verify_gender_use_case.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/data_controller.dart';
import 'package:voiceclub_partner/features/onboarding/views/earning_potential/earning_potential_screen.dart';

class FaceVerificationController extends GetxController {
  final image = Rxn<File>();
  final faceVerificationState = FaceVerificationState.Incomplete.obs;

  /// Continue Action
  void continueAction() async {
    sl<AnalyticsService>().trackEvent("submitImageVerification");
    if (faceVerificationState.value == FaceVerificationState.Rejected) {
      launchUrl(Uri.parse(URLConstants.userAppPlayStoreUrl));
    } else if (faceVerificationState.value == FaceVerificationState.Accepted) {
      await Get.find<DataController>().updateData(
        profileStatus: ProfileStatus.PENDING,
      );
      Get.offAll(() => const EarningPotentialScreen());
    } else if (image.value != null) {
      checkLiveness();
    }
  }

  Future<void> checkLiveness() async {
    if (image.value == null) return;

    final isIdtoEnabled = sl<GrowthBookService>().isFeatureEnabled(
      FeatureFlag.idto,
    );
    final livenessType = isIdtoEnabled ? "idto" : "hyperverge";

    sl<AnalyticsService>().trackEvent(
      "livenessCheckInitiated",
      eventProperties: {"type": livenessType},
    );

    try {
      Get.context?.loaderOverlay.show();

      bool? isValid;
      String? failureReason;
      String? errorMessage;
      String? transactionId;
      String? apiErrorMessage;

      if (isIdtoEnabled) {
        final response = await sl<CheckLivenessIdtoUseCase>().call(
          CheckLivenessIdtoParams(image: image.value!),
        );
        if (response.data != null) {
          final validation = response.data!.validationResult;
          isValid = validation.isValid;
          failureReason = validation.failureReason;
          errorMessage = validation.errorMessage;
        } else if (response.error != null) {
          apiErrorMessage = response.errorMessage;
        }
      } else {
        final response = await sl<CheckLivenessHypervergeUseCase>().call(
          CheckLivenessHypervergeParams(image: image.value!),
        );
        if (response.data != null) {
          final validation = response.data!.validationResult;
          isValid = validation.isValid;
          failureReason = validation.failureReason;
          errorMessage = validation.errorMessage;
          transactionId = response.data?.metadata?.transactionId;
        } else if (response.error != null) {
          apiErrorMessage = response.errorMessage;
        }
      }

      _handleLivenessResult(
        isValid: isValid,
        failureReason: failureReason,
        errorMessage: errorMessage,
        transactionId: transactionId,
        apiErrorMessage: apiErrorMessage,
        livenessType: livenessType,
      );
    } catch (e) {
      Logger.logError("Error in checkLiveness ${e.toString()}");
      sl<AnalyticsService>().trackEvent(
        "livenessCheckFailed",
        eventProperties: {"reason": e.toString(), "type": livenessType},
      );
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.errorTitle.tr,
        subtitle: LocaleKeys.livenessUnexpectedError.tr,
      );
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  /// Handles the liveness check result uniformly regardless of provider
  void _handleLivenessResult({
    required bool? isValid,
    required String? failureReason,
    required String? errorMessage,
    required String? transactionId,
    required String? apiErrorMessage,
    required String livenessType,
  }) {
    if (isValid != null) {
      if (isValid) {
        Logger.logMessage("Liveness check passed successfully");
        sl<AnalyticsService>().trackEvent(
          "livenessCheckPassed",
          eventProperties: {
            "transaction_id": transactionId,
            "type": livenessType,
          },
        );
        _uploadFile();
      } else {
        Logger.logError("Liveness check failed: $failureReason");
        sl<AnalyticsService>().trackEvent(
          "livenessCheckFailed",
          eventProperties: {
            "reason": failureReason,
            "transaction_id": transactionId,
            "type": livenessType,
          },
        );
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.livenessCheckFailed.tr,
          subtitle: errorMessage ?? LocaleKeys.validationFailed.tr,
        );
      }
    } else if (apiErrorMessage != null) {
      Logger.logError("Liveness API error: $apiErrorMessage");
      sl<AnalyticsService>().trackEvent(
        "livenessCheckFailed",
        eventProperties: {"reason": apiErrorMessage, "type": livenessType},
      );
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.errorTitle.tr,
        subtitle: apiErrorMessage,
      );
    }
  }

  /// Retake
  void retakeAction() {
    try {
      image.value = null;
      faceVerificationState.value = FaceVerificationState.Incomplete;
      sl<AnalyticsService>().trackEvent("retakeImage");
    } catch (e) {
      Logger.logError("error in retakeAction ${e.toString()}");
    }
  }

  /// **Upload File using Uint8List**
  Future<void> _uploadFile() async {
    if (image.value == null) return;

    try {
      Get.context?.loaderOverlay.show();

      if (image.value != null) {
        final response = await sl<UploadOnboardingFileUsecase>().call(
          UploadOnboardingFileParams(file: image.value!),
        );
        if (response.data != null && response.error == null) {
          _checkGender(response.data!);
        } else {
          Logger.logError("Error uploading file: ${response.errorMessage}");
        }
      }
    } catch (e) {
      Logger.logError("Error uploading file: $e");
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  Future<void> _checkGender(
    UploadFileResponseModel uploadFileResponseModel,
  ) async {
    try {
      Get.context?.loaderOverlay.show();
      if (image.value != null) {
        Map<String, dynamic> s3Object = {
          "Bucket": uploadFileResponseModel.bucket,
          "Name": uploadFileResponseModel.file,
        };
        final response = await sl<VerifyGenderUseCase>().call(
          VerifyGenderParams(s3Object: s3Object),
        );
        if (response.data != null && response.error == null) {
          final imageUrl =
              "https://${uploadFileResponseModel.bucket}.s3.ap-south-1.amazonaws.com/${uploadFileResponseModel.file}";
          if (response.data?.value?.toLowerCase().contains("female") ?? false) {
            faceVerificationState.value = FaceVerificationState.Accepted;
            Logger.logError(
              "Setting image path to ${uploadFileResponseModel.file}",
            );
            Get.find<DataController>().onboardingDataModel.value.imagePath =
                uploadFileResponseModel.file;
            Get.find<DataController>().updateData(
              profileStatus: ProfileStatus.PENDING,
            );
            sl<AnalyticsService>().trackEvent(
              "imageVerificationSuccess",
              eventProperties: {"imageUrl": imageUrl},
            );
          } else {
            faceVerificationState.value = FaceVerificationState.Rejected;
            sl<AnalyticsService>().trackEvent(
              "imageVerificationFailed",
              eventProperties: {"imageUrl": imageUrl},
            );
          }
        }
      }
    } catch (e) {
      Logger.logError("Error in checkGender ${e.toString()}");
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }
}
