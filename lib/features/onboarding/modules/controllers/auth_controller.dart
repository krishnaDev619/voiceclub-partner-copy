import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/app_language_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/local_data_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/auth/profile_response.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/update_data/onboarding_data_model.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/auth/get_profile.dart'
    as get_profile;
import 'package:voiceclub_partner/features/onboarding/domain/usecases/update_data/complete_onboarding.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/update_data/get_file_url.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/data_controller.dart';
import 'package:voiceclub_partner/features/onboarding/views/agreement/onboarding_failure_screen.dart';
import 'package:voiceclub_partner/features/onboarding/views/agreement/view_signed_agreement_screen.dart';
import 'package:voiceclub_partner/features/onboarding/views/earning_potential/earning_potential_screen.dart';
import 'package:voiceclub_partner/features/onboarding/views/onboarding/onboarding_screen.dart';
import 'package:voiceclub_partner/features/onboarding/views/post_onboarding/congratulations_screen.dart';
import 'package:voiceclub_partner/features/onboarding/views/post_onboarding/interview_result_screen.dart';
import 'package:voiceclub_partner/features/onboarding/views/post_onboarding/verified_screen.dart';
import 'package:voiceclub_partner/features/onboarding/views/video_screen/agreement_video_screen.dart';
import 'package:voiceclub_partner/features/onboarding/views/video_screen/meeting_one_video_screen.dart';

class AuthController extends GetxController {
  final phoneNoValue = "".obs;
  final profileResponseModel = ProfileResponseModel().obs;
  final currentAppLocale = AppLanguage.Hindi.obs;
  final isLoading = false.obs;

  Future<void> updateAppLocale() async {
    var appLocale = await sl<AppLanguageService>().getSavedLocale();
    AppLanguage appLanguage = appLocale.toAppLanguage();
    currentAppLocale(appLanguage);
    Get.find<DataController>().onboardingDataModel.value.appLanguage =
        currentAppLocale.value.name;
  }

  void goToM1VideoScreen() {
    Get.offAll(() => const MeetingOneVideoScreen());
  }

  void goToCongratulationsScreen() {
    Get.offAll(() => CongratulationsScreen());
  }

  void goToVerifiedScreen(bool isVerified) {
    Get.offAll(() => VerifiedScreen(isVerified: isVerified));
  }

  void goToEarningPotentialScreen() {
    Get.offAll(() => const EarningPotentialScreen());
  }

  void goToOnboardingScreen() {
    Get.offAll(() => const OnboardingScreen());
  }

  void goToInterviewResultScreen({bool isPassed = false}) {
    Get.offAll(
      () => InterviewResultScreen(isPassed: isPassed, eventProperties: {}),
    );
  }

  void goToOnboardingFailureScreen(String documentPath) {
    Get.offAll(() => OnboardingFailureScreen(documentPath: documentPath));
  }

  void goToAgreementScreen() {
    Get.offAll(() => const AgreementVideoScreen());
  }

  Future<void> navigateBasedOnStatus() async {
    var earningPotential = await sl<LocalDataService>().getEarningPotential();
    Get.find<DataController>().earningPotential.value = earningPotential;
    final status = profileResponseModel.value.profileStatus;

    if (status == ProfileStatus.PENDING ||
        status == ProfileStatus.M2 ||
        status == ProfileStatus.RNR2) {
      // Step 1 : Check Face Verification Status
      if (profileResponseModel.value.imagePath?.isEmpty ?? true) {
        goToM1VideoScreen();
        return;
      }

      // Step 2 : Check Pan Verification Status
      if (profileResponseModel.value.name?.isEmpty ?? true) {
        goToEarningPotentialScreen();
        return;
      }

      // Step 3 : Check Earning Potential
      if (earningPotential.isEmpty) {
        goToEarningPotentialScreen();
        return;
      }

      if (profileResponseModel.value.signedLegalDocumentPath?.isEmpty ?? true) {
        goToInterviewResultScreen(isPassed: true);
        return;
      } else {
        goToOnboardingFailureScreen(
          profileResponseModel.value.signedLegalDocumentPath ?? "",
        );
        return;
      }
    } else if (status == ProfileStatus.REJECTED) {
      goToInterviewResultScreen(isPassed: false);
      return;
    } else if (status == ProfileStatus.APPROVED) {
      if (profileResponseModel.value.signedLegalDocumentPath?.isEmpty ?? true) {
        goToInterviewResultScreen(isPassed: true);
        return;
      } else {
        goToOnboardingFailureScreen(
          profileResponseModel.value.signedLegalDocumentPath ?? "",
        );
        return;
      }
    } else if (profileResponseModel.value.profileStatus ==
        ProfileStatus.ACCOUNT_ONBOARDED) {
      goToCongratulationsScreen();
      return;
    }
  }

  Future<void> getProfile(String phoneNo, {bool shouldNavigate = true}) async {
    try {
      Get.context?.loaderOverlay.show();
      isLoading(true);
      phoneNoValue.value = phoneNo;
      var getProfileUseCase = sl<get_profile.GetProfileUseCase>();
      var response = await getProfileUseCase.call(NoParams());
      if (response.data != null && response.error == null) {
        profileResponseModel.value = response.data ?? ProfileResponseModel();
        Get.find<DataController>()
            .onboardingDataModel
            .value = OnboardingDataModel.fromProfileResponseModel(
          profileResponseModel.value,
        );
        Logger.logError(
          "Profile response model: ${profileResponseModel.value.toJson()}",
        );
        sl<GrowthBookService>().setAttributes(
          phoneNumber: profileResponseModel.value.phone ?? "",
          appLanguage: currentAppLocale.value.name,
        );
        sl<AnalyticsService>().trackEnabledGrowthBookFeatures();
        // Comment this and add any manual routes here
        if (shouldNavigate) navigateBasedOnStatus();
      }
    } catch (_) {
    } finally {
      Get.context?.loaderOverlay.hide();
      isLoading(false);
      update();
    }
  }

  Future<File?> getSignedDocumentFile() async {
    try {
      var registerResponse =
          Get.find<AuthController>().profileResponseModel.value;
      var response = await sl<GetFileUrlUseCase>().call(
        GetFileUrlParams(
          fileName: registerResponse.signedLegalDocumentPath ?? "",
        ),
      );
      if (response.data?.url?.isNotEmpty ?? false) {
        File file = await DefaultCacheManager().getSingleFile(
          response.data?.url ?? "",
        );
        return file;
      }
    } catch (e) {
      Logger.logError(e.toString());
    } finally {}
    return null;
  }

  /// Complete onboarding with retry logic
  /// Returns true if successful, false if failed after all retries
  Future<bool> completeOnboarding(String signedDocumentPath) async {
    const int maxRetries = 3;
    int currentRetry = 0;

    while (currentRetry < maxRetries) {
      try {
        currentRetry++;
        Logger.logError(
          "Attempting complete onboarding - Attempt $currentRetry of $maxRetries",
        );

        final response = await sl<CompleteOnboardingUseCase>().call(
          CompleteOnboardingParams(
            phone: profileResponseModel.value.phone ?? "",
            bypassKyc: true,
          ),
        );

        if (response.error == null) {
          sl<AnalyticsService>().trackEvent("onboardingSuccessful");
          return true;
        } else {
          Logger.logError(
            "Complete onboarding failed on attempt $currentRetry: ${response.error}",
          );
          if (currentRetry >= maxRetries) {
            return false;
          }
        }
      } catch (e) {
        Logger.logError(
          "Error in completeOnboarding attempt $currentRetry: ${e.toString()}",
        );
        if (currentRetry >= maxRetries) {
          return false;
        }
      }

      // Wait before retrying (exponential backoff)
      if (currentRetry < maxRetries) {
        await Future.delayed(Duration(seconds: currentRetry * 2));
      }
    }

    return false; // All retries failed
  }

  /// Get signed document URL
  Future<String?> _getSignedDocumentUrl(String fileName) async {
    try {
      final response = await sl<GetFileUrlUseCase>().call(
        GetFileUrlParams(fileName: fileName),
      );
      if (response.data != null && response.error == null) {
        String fileUrl = response.data?.url ?? "";
        return fileUrl;
      }
    } catch (e) {
      Logger.logError("Error in getSignedDocumentUrl ${e.toString()}");
    }
    return null;
  }

  /// Retry complete onboarding with profile status check
  Future<void> retryCompleteOnboarding(String documentPath) async {
    try {
      Get.context?.loaderOverlay.show();
      final isSuccess = await completeOnboarding(documentPath);

      if (isSuccess) {
        // Refresh profile to check status
        await getProfile(
          profileResponseModel.value.phone ?? "",
          shouldNavigate: false,
        );

        // Check if status is ACCOUNT_ONBOARDED
        if (profileResponseModel.value.profileStatus ==
            ProfileStatus.ACCOUNT_ONBOARDED) {
          Get.context?.loaderOverlay.hide();
          goToCongratulationsScreen();
        } else {
          // If not ACCOUNT_ONBOARDED, navigate to signed agreement screen
          final signedDocumentUrl = await _getSignedDocumentUrl(documentPath);
          if (signedDocumentUrl?.isNotEmpty == true) {
            Get.context?.loaderOverlay.hide();
            Get.offAll(
              () => ViewSignedAgreementScreen(
                signedDocumentUrl: signedDocumentUrl ?? "",
              ),
            );
          } else {
            Get.context?.loaderOverlay.hide();
            // Stay on failure screen if URL fetch fails
          }
        }
      } else {
        // Stay on failure screen for another retry
        Get.context?.loaderOverlay.hide();
      }
    } catch (e) {
      Logger.logError("Error in retryCompleteOnboarding: ${e.toString()}");
      Get.context?.loaderOverlay.hide();
    }
  }
}
