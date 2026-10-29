import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:restart_app/restart_app.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/string_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/app_preferences.dart';
import 'package:voiceclub_partner/core/services/config_fcm_service.dart';
import 'package:voiceclub_partner/core/services/deeplink_language.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/ui_localization_service.dart';
import 'package:voiceclub_partner/core/services/session_router.dart';
import 'package:voiceclub_partner/core/services/token_service.dart';
import 'package:voiceclub_partner/data/models/data.dart';
import 'package:voiceclub_partner/data/models/metrics/get_probation_details_response.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_profile.dart';
import 'package:voiceclub_partner/domain/usecases/auth/logout.dart';
import 'package:voiceclub_partner/domain/usecases/metrics/get_metrics_score.dart';
import 'package:voiceclub_partner/domain/usecases/metrics/get_probation_details.dart';
import 'package:voiceclub_partner/modules/bindings/landing_binding.dart';
import 'package:voiceclub_partner/modules/bindings/onboarding_binding.dart';
import 'package:voiceclub_partner/view/auth/login_screen.dart';
import 'package:voiceclub_partner/view/landing/landing_screen.dart';
import 'package:voiceclub_partner/view/landing/retry_screen.dart';
import 'package:voiceclub_partner/view/onboarding/onboarding_welcome_screen.dart';

class AuthService {
  final Dio _dio;
  final TokenService _tokenService;
  final AppPreferences _preferences;

  AuthService(this._dio, this._tokenService, this._preferences);

  Future<void> setAuthorizationToken(String token) async {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    await _tokenService.setToken(token);
  }

  Future<void> saveAccountType(AccountType accountType) async {
    await _preferences.setString(
      AppPreferences.accountTypeKey,
      accountType.name,
    );
  }

  Future<void> saveLoginDetails(String token, AccountType accountType) async {
    await setAuthorizationToken(token);
    await saveAccountType(accountType);
  }

  Future<AccountType?> getAccountType() async {
    final type = await _preferences.getString(AppPreferences.accountTypeKey);
    if (type != null) {
      if (type == AccountType.DEMAND.name) {
        return AccountType.DEMAND;
      } else {
        return AccountType.SUPPLY;
      }
    } else {
      return null;
    }
  }

  Future<String?> getAuthorizationToken() async {
    return _tokenService.getToken();
  }

  Future<Map<String, String>> getAuthorizationHeader() async {
    Map<String, String> header = {};
    header['Authorization'] = 'Bearer ${await getAuthorizationToken() ?? ''}';
    return header;
  }

  Future<bool> isLoggedIn() async {
    final loggedIn = await _tokenService.isLoggedIn();
    if (loggedIn) {
      final token = await _tokenService.getToken();
      Logger.logMessage("Token: $token", name: "Token");
      if (token?.isNotEmpty ?? false) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      return true;
    }
    _dio.options.headers.remove('Authorization');
    return false;
  }

  Future<void> checkUser() async {
    Get.context?.loaderOverlay.show();
    final loggedIn = await isLoggedIn();
    Logger.logMessage("Logged In: $loggedIn", name: "Auth Service");
    if (!loggedIn) {
      Get.context?.loaderOverlay.hide();
      Get.offAll(() => const LoginScreen());
      return;
    }
    await SessionRouter.resolveInitialRoute();
  }

  Future<void> landingNavigation() async {
    final userDataResponse = await sl<GetProfileUsecase>().call(NoParams());
    final probationDataResponse = await sl<GetProbationDetailsUsecase>().call(
      NoParams(),
    );
    if (userDataResponse.data?.accountId != null &&
        userDataResponse.data?.user?.id != null &&
        userDataResponse.data?.onboardingStage != null &&
        probationDataResponse.data != null &&
        probationDataResponse.data?.stage != null &&
        probationDataResponse.data?.stage != PartnerCurrentStatus.NULL) {
      await DeeplinkLanguage.useBackendLanguage(
        userDataResponse.data?.primaryLanguage,
      );
      final preferredLanguage = userDataResponse.data?.primaryLanguage?.trim();
      if (preferredLanguage != null && preferredLanguage.isNotEmpty) {
        await sl<UiLocalizationService>().applyPreferredLanguage(
          preferredLanguage,
        );
      }
      await sl<UiLocalizationService>().ensureBundledEnglish(
        updateLocale: true,
      );

      ConfigFCMService.updateFCM();

      final probationStatus = probationDataResponse.data!.stage!;

      final metricsDataResponse = await sl<GetMetricsScoreUseCase>().call(
        GetMetricsScoreParams(scoreOnly: true),
      );
      final oneScore = metricsDataResponse.data?.aggregate?.score?.toInt() ?? 0;

      setGrowthBookAttributes(
        userId: userDataResponse.data?.user?.id,
        language: userDataResponse.data?.primaryLanguage,
        secondaryLanguage: userDataResponse.data?.secondaryLanguage,
        currentStatus: probationStatus,
        oneScore: oneScore,
        createdAt: userDataResponse.data?.createdAt ?? '',
      );
      await sl<IntroAudioPolicyService>().fetch();
      await sl<IntroAudioPolicyService>().hasPassedNewLiveIntro(
        userDataResponse.data?.accountId ?? 0,
      );
      if (probationStatus == PartnerCurrentStatus.LIVE ||
          probationStatus == PartnerCurrentStatus.FIRED) {
        Get.context?.loaderOverlay.hide();
        navigateToLandingScreen(
          userDataResponse.data!,
          probationDataResponse.data!,
        );
      } else if (probationStatus == PartnerCurrentStatus.ONBOARDED) {
        Get.context?.loaderOverlay.hide();
        navigateToOnboardingScreen(
          userDataResponse.data!,
          probationDataResponse.data!,
        );
      } else {
        if (sl<UiLocalizationService>().journey?.stages?.isNotEmpty ?? false) {
          Get.context?.loaderOverlay.hide();
          navigateToOnboardingScreen(
            userDataResponse.data!,
            probationDataResponse.data!,
          );
        } else {
          Get.context?.loaderOverlay.hide();
          Get.offAll(() => RetryScreen(errorReason: "Journey data not found"));
        }
      }
    } else {
      Get.context?.loaderOverlay.hide();
      String? errorReason;

      if (userDataResponse.data == null) {
        errorReason = "User Data Response is null";
      } else if (userDataResponse.data?.accountId == null) {
        errorReason = "Account ID is null";
      } else if (userDataResponse.data?.user?.id == null) {
        errorReason = "User ID is null";
      } else if (userDataResponse.data?.onboardingStage == null) {
        errorReason = "Onboarding Stage is null";
      } else if (probationDataResponse.data == null) {
        errorReason = "Probation Data Response is null";
      } else if (probationDataResponse.data?.stage == null) {
        errorReason = "Probation Stage is null";
      } else if (probationDataResponse.data?.stage ==
          PartnerCurrentStatus.NULL) {
        errorReason = "Probation Stage is null";
      }
      Get.offAll(
        () => RetryScreen(errorReason: errorReason ?? "Restart your app."),
      );
    }
  }

  // Set GrowthBook attributes before navigation because GrowthBook flagged is used before setting attributes
  void setGrowthBookAttributes({
    required int? userId,
    required String? language,
    required String? secondaryLanguage,
    required PartnerCurrentStatus currentStatus,
    required int oneScore,
    required String createdAt,
  }) {
    if (userId != null && userId > 0) {
      sl<GrowthBookService>().setAttributes(
        userId: userId,
        language: language,
        secondaryLanguage: secondaryLanguage,
        currentStatus: currentStatus,
        oneScore: oneScore,
        createdAt: createdAt,
      );
    }
  }

  void navigateToOnboardingScreen(
    DataModel userDataModel,
    GetProbationDetailsResponseModel initProbationData,
  ) {
    Get.offAll(
      () => const OnboardingWelcomeScreen(),
      binding: OnboardingBinding(
        userDataModel: userDataModel,
        initProbationData: initProbationData,
      ),
    );
  }

  void navigateToLandingScreen(
    DataModel userDataModel,
    GetProbationDetailsResponseModel initProbationData,
  ) {
    Get.offAll(
      () => const LandingScreen(),
      binding: LandingBinding(
        userDataModel: userDataModel,
        initProbationData: initProbationData,
      ),
    );
  }

  Future<void> removeLoginDetails() async {
    await _tokenService.clearToken();
    await _preferences.remove(AppPreferences.accountTypeKey);
    await _dio.options.headers.remove('Authorization');
  }

  Future<void> closeAndDeleteAllHiveData() async {
    try {
      // Close all open Hive boxes
      await Hive.close();

      // Iterate and delete each box
      await Hive.deleteBoxFromDisk(StringConstants.chatGroupsBoxName);
      await Hive.deleteBoxFromDisk(StringConstants.messageCountBoxName);
      await Hive.deleteBoxFromDisk(StringConstants.fetchedMessageCountBoxName);
      await Hive.deleteBoxFromDisk(StringConstants.scrollPostionBoxName);
    } catch (_) {}
  }

  void logout() async {
    try {
      Get.context?.loaderOverlay.show();
      final response = await sl<LogoutUsecase>().call(NoParams());
      if (response.error != null &&
          response.error?.response?.statusCode != 401) {
        final data = response.error?.response?.data;
        final errorMessage = data?['message'] ?? 'Please try again later!';
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: errorMessage,
          subtitle: "Please try again",
        );
      } else {
        if (response.error?.response?.statusCode == 401) {
          final data = response.error?.response?.data;
          final errorMessage = data?['message'] ?? 'Please try again later!';
          final detailMessage = data?['detail'] ?? 'Please try again later!';
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Error,
            title: errorMessage.toString(),
            subtitle: detailMessage.toString(),
          );
        }
        sl<AnalyticsService>().trackEvent("logout");
        await sl<AnalyticsService>().reset();
        await removeLoginDetails();
        await _preferences.clearAll();
        await closeAndDeleteAllHiveData();
        Get.deleteAll(force: true);
        Get.context?.loaderOverlay.hide();
        Restart.restartApp(forceKill: true, mode: RestartMode.process);
      }
    } catch (_) {
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }
}

class IsolateAuthService {
  final Dio _dio;

  IsolateAuthService(this._dio);

  Future<bool> isLoggedIn() async {
    final authToken = await TokenService.readStoredToken();
    if (authToken?.isNotEmpty ?? false) {
      _dio.options.headers['Authorization'] = 'Bearer $authToken';
      return true;
    }
    _dio.options.headers.remove('Authorization');
    return false;
  }
}
