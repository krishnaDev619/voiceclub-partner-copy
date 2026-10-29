import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:restart_app/restart_app.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/auth_service.dart';
import 'package:voiceclub_partner/core/services/deeplink_language.dart';
import 'package:voiceclub_partner/core/services/location_service.dart';
import 'package:voiceclub_partner/core/services/token_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart'
    as onboarding_enums;
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart'
    as onboarding_di;
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/app_language_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/local_data_service.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/auth/profile_response.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/update_data/onboarding_data_model.dart';
import 'package:voiceclub_partner/features/onboarding/views/auth/app_language_selection.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/auth/get_profile.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/auth_controller.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/data_controller.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/onboarding_controller.dart';
import 'package:voiceclub_partner/view/auth/login_screen.dart';

class SessionRouter {
  SessionRouter._();

  static Future<void> resolveInitialRoute() async {
    final tokenService = sl<TokenService>();
    if (!await tokenService.isLoggedIn()) {
      Get.context?.loaderOverlay.hide();
      Get.offAll(() => const LoginScreen());
      return;
    }

    final phone = await onboarding_di.sl<LocalDataService>().getPhoneNumber();

    if (phone.isEmpty) {
      Get.context?.loaderOverlay.hide();
      Get.offAll(() => const LoginScreen());
      return;
    }

    await _routeByProfile(phone);
  }

  static Future<void> onOtpVerified({
    required String phoneNo,
    required String accessToken,
  }) async {
    await sl<TokenService>().setToken(accessToken);
    await onboarding_di.sl<LocalDataService>().savePhoneNumber(phoneNo);
    await _routeByProfile(phoneNo);
  }

  static Future<void> enterPartnerFlow() async {
    final authService = sl<AuthService>();
    await authService.saveAccountType(AccountType.SUPPLY);
    authService.landingNavigation();
  }

  /// Enters the partner app after supply onboarding completes.
  /// Restarts the app when onboarding GetX controllers are still registered.
  static Future<void> startPartnerAppFromOnboarding() async {
    await sl<AuthService>().saveAccountType(AccountType.SUPPLY);

    if (_shouldRestartBeforePartnerFlow()) {
      Restart.restartApp();
      return;
    }

    await enterPartnerFlow();
  }

  static bool _shouldRestartBeforePartnerFlow() {
    return Get.isRegistered<AuthController>() ||
        Get.isRegistered<DataController>() ||
        Get.isRegistered<OnboardingController>();
  }

  /// Called after the user picks a language on [AppLanguageSelection].
  static Future<void> onLanguageSelected() async {
    if (!await sl<TokenService>().isLoggedIn()) {
      Get.offAll(() => const LoginScreen());
      return;
    }

    final authController = Get.find<AuthController>();
    await authController.navigateBasedOnStatus();
  }

  static Future<void> _routeByProfile(String phoneNo) async {
    Get.context?.loaderOverlay.show();
    try {
      final profileResponse = await onboarding_di.sl<GetProfileUseCase>().call(
        NoParams(),
      );

      if (profileResponse.data == null || profileResponse.error != null) {
        Get.context?.loaderOverlay.hide();
        Get.offAll(() => const LoginScreen());
        return;
      }

      final profile = profileResponse.data!;
      if (profile.profileStatus ==
          onboarding_enums.ProfileStatus.ACCOUNT_ONBOARDED) {
        await sl<LocationService>().initialize();
        await enterPartnerFlow();
        return;
      }

      await _enterOnboardingFlow(phoneNo: phoneNo, profile: profile);
    } catch (_) {
      Get.context?.loaderOverlay.hide();
      Get.offAll(() => const LoginScreen());
    }
  }

  static Future<void> _enterOnboardingFlow({
    required String phoneNo,
    required ProfileResponseModel profile,
  }) async {
    ensureOnboardingControllers();
    final authController = Get.find<AuthController>();
    authController.phoneNoValue.value = phoneNo;
    authController.profileResponseModel.value = profile;
    final dataController = Get.find<DataController>();
    dataController
        .onboardingDataModel
        .value = OnboardingDataModel.fromProfileResponseModel(profile);
    final pendingLanguage = await DeeplinkLanguage.pendingLanguage();
    if (pendingLanguage != null) {
      await DeeplinkLanguage.applyUiLanguage(pendingLanguage);
      dataController.onboardingDataModel.value.firstLanguage = pendingLanguage;
    }
    await authController.updateAppLocale();
    _applyOnboardingProfileSideEffects(authController, profile);

    if (!await onboarding_di.sl<AppLanguageService>().hasSavedLocale()) {
      Get.context?.loaderOverlay.hide();
      Get.offAll(() => const AppLanguageSelection());
      return;
    }

    Get.context?.loaderOverlay.hide();
    await authController.navigateBasedOnStatus();
  }

  static void _applyOnboardingProfileSideEffects(
    AuthController authController,
    ProfileResponseModel profile,
  ) {
    onboarding_di.sl<GrowthBookService>().setAttributes(
      phoneNumber: profile.phone ?? "",
      appLanguage: authController.currentAppLocale.value.name,
    );
    onboarding_di.sl<AnalyticsService>().trackEnabledGrowthBookFeatures();
  }

  static void ensureOnboardingControllers() {
    if (!Get.isRegistered<DataController>()) {
      Get.put(DataController(), permanent: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<OnboardingController>()) {
      Get.put(OnboardingController(), permanent: true);
    }
  }
}
