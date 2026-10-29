import 'package:voiceclub_partner/core/services/app_preferences.dart';
import 'package:voiceclub_partner/core/services/token_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

class LocalDataService {
  final AppPreferences _preferences;
  final TokenService _tokenService;

  LocalDataService(this._preferences, this._tokenService);

  Future<void> setAuthorizationToken(String token) async {
    await _tokenService.setToken(token);
  }

  Future<String?> getAuthorizationToken() async {
    return _tokenService.getToken();
  }

  Future<bool> getIsLoggedIn() async {
    return _tokenService.isLoggedIn();
  }

  Future<void> _removeLoginDetails() async {
    await _tokenService.clearToken();
    await _preferences.clearOnboardingSessionData();
  }

  Future<void> savePhoneNumber(String phone) async {
    Logger.logMessage(
      "Saving phone number: $phone",
      name: "Local Data Service",
    );
    await _preferences.setString(AppPreferences.phoneKey, phone);
  }

  Future<String> getPhoneNumber() async {
    return await _preferences.getString(AppPreferences.phoneKey) ?? "";
  }

  Future<void> setEarningPotential(String earningPotential) async {
    await _preferences.setString(
      AppPreferences.earningPotentialKey,
      earningPotential,
    );
  }

  Future<String> getEarningPotential() async {
    return await _preferences.getString(AppPreferences.earningPotentialKey) ??
        "";
  }

  Future<void> logout() async {
    sl<AnalyticsService>().reset();
    await _removeLoginDetails();
  }
}
