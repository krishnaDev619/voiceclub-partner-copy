import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/facebook_event_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/update_data/onboarding_data_model.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/update_data/update_data.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/auth_controller.dart';

class DataController extends GetxController {
  final onboardingDataModel = OnboardingDataModel().obs;
  final earningPotential = "₹30,000".obs;

  // Store first language temporary because first language in profile is Hindi
  final selectedFirstLanguage = Rxn<Language>();

  Future<void> updateData({
    bool isLastUpdate = false,
    required ProfileStatus profileStatus,
    bool shouldNavigate = false,
  }) async {
    try {
      Get.context?.loaderOverlay.show();
      onboardingDataModel.value.profileStatus = profileStatus;
      var response = await sl<UpdateDataUseCase>().call(
        Params(updateDataModel: onboardingDataModel.value),
      );
      if (response.data != null && response.error == null) {
        await Get.find<AuthController>().getProfile(
          onboardingDataModel.value.phone ?? "",
          shouldNavigate: shouldNavigate,
        );
        if (isLastUpdate) {
          sl<AnalyticsService>().trackEvent("dataUpdated");
          FacebookEventService.trackCompleteRegistration();
          sl<AnalyticsService>().firebaseAnalytics.logSignUp(
            signUpMethod: "OTP",
          );
        }
      }
    } catch (_) {
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }
}
