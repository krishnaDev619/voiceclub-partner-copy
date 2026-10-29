import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:restart_app/restart_app.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/domain/usecases/account/mark_onboarding_completed.dart';

class PartnerOnboardingCompletionService {
  PartnerOnboardingCompletionService._();

  static bool _isRunning = false;

  static Future<bool> completeSilently({
    required bool isFromAi,
    bool closeBottomSheetBeforeApi = false,
  }) async {
    if (_isRunning) {
      return false;
    }

    _isRunning = true;
    try {
      if (closeBottomSheetBeforeApi && (Get.isBottomSheetOpen ?? false)) {
        Get.back();
      }

      Get.context?.loaderOverlay.show();
      final response = await sl<MarkOnboardingCompletedUseCase>().call(
        NoParams(),
      );

      if (response.error == null) {
        sl<AnalyticsService>().trackEvent(
          "onboardingAutoCompleted",
          eventProperties: {
            "isFromAi": isFromAi,
            ...sl<IntroAudioPolicyService>().analyticsProperties,
          },
        );
        await sl<AnalyticsService>().fireStartTrialEvents();
        Restart.restartApp();
        return true;
      }

      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: 'Error',
        subtitle:
            response.error?.response?.data['message'] ??
            'Something went wrong. Please try again.',
      );
      return false;
    } catch (e, stack) {
      Logger.logMessage(
        "Error completing partner onboarding: $e\n$stack",
        name: 'PartnerOnboardingCompletionService',
      );
      return false;
    } finally {
      Get.context?.loaderOverlay.hide();
      _isRunning = false;
    }
  }
}
