import 'package:voiceclub_partner/core/services/app_preferences.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';

class AppLanguageService {
  final AppPreferences _preferences;

  AppLanguageService(this._preferences);

  Future<void> saveLocale(String locale) async {
    await _preferences.setString(AppPreferences.appLocaleKey, locale);
  }

  Future<String> getSavedLocale() async {
    final value = await _preferences.getString(AppPreferences.appLocaleKey);
    return value ?? AppLanguage.Hindi.name;
  }

  Future<bool> hasSavedLocale() async {
    return _preferences.containsKey(AppPreferences.appLocaleKey);
  }

  Future<void> saveDeeplinkLanguage(String language) {
    return _preferences.setString(AppPreferences.deeplinkLanguageKey, language);
  }

  Future<String?> readDeeplinkLanguage() async {
    final value = await _preferences.getString(
      AppPreferences.deeplinkLanguageKey,
    );
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> clearDeeplinkLanguage() {
    return _preferences.remove(AppPreferences.deeplinkLanguageKey);
  }
}
