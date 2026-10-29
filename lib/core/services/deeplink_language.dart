import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/token_service.dart';
import 'package:voiceclub_partner/core/services/ui_localization_service.dart';
import 'package:voiceclub_partner/data/models/localization/ui_language.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/app_language_service.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/auth_controller.dart';

/// Matches [raw] to a language from the backend list.
///
/// The match can be the language code, the app language name, or the display
/// name. The returned value is the app language name when the list has one,
/// otherwise the code. A language that is not in the list is ignored.
String? listedLanguageToken(String? raw, List<UiLanguage> languages) {
  final value = raw?.trim().toLowerCase();
  if (value == null || value.isEmpty) return null;
  for (final language in languages) {
    final code = language.code.toLowerCase();
    final appLanguage = language.appLanguage?.trim().toLowerCase();
    final name = language.name.trim().toLowerCase();
    if (value != code && value != appLanguage && value != name) continue;
    final stored = language.appLanguage?.trim();
    if (stored != null && stored.isNotEmpty) return stored;
    return language.code;
  }
  return null;
}

class DeeplinkLanguage {
  /// Saves the deeplink language and switches the auth screens to it.
  ///
  /// A partner who is already logged in keeps the language from their account.
  static Future<void> capture(
    Uri link, {
    required String source,
    bool? isDeferred,
  }) async {
    final rawLanguage = _rawParam(link);
    if (rawLanguage == null) return;

    final properties = <String, dynamic>{
      'requestedLanguage': rawLanguage,
      'source': source,
      if (isDeferred != null) 'isDeferred': isDeferred,
    };
    final language = listedLanguageToken(
      rawLanguage,
      sl<UiLocalizationService>().languages,
    );
    if (language == null) return;

    if (await sl<TokenService>().isLoggedIn()) {
      sl<AnalyticsService>().trackEvent(
        'deeplinkAppLanguageIgnored',
        eventProperties: {...properties, 'reason': 'already_logged_in'},
      );
      return;
    }

    await sl<AppLanguageService>().saveDeeplinkLanguage(language);
    await applyUiLanguage(language);
    sl<AnalyticsService>().trackEvent(
      'deeplinkAppLanguageSelected',
      eventProperties: {...properties, 'selectedLanguage': language},
    );
  }

  /// Language saved from a deeplink, still waiting to be used or dropped.
  static Future<String?> pendingLanguage() {
    return sl<AppLanguageService>().readDeeplinkLanguage();
  }

  /// Existing partner: forget the deeplink language and use [talkLanguage].
  static Future<void> useBackendLanguage(String? talkLanguage) async {
    final pending = await sl<AppLanguageService>().readDeeplinkLanguage();
    if (pending == null) return;
    await sl<AppLanguageService>().clearDeeplinkLanguage();
    final language = listedLanguageToken(
      talkLanguage,
      sl<UiLocalizationService>().languages,
    );
    if (language == null) return;
    await applyUiLanguage(language);
  }

  static Future<void> applyUiLanguage(String language) async {
    await sl<AppLanguageService>().saveLocale(language);
    await sl<UiLocalizationService>().applyToken(language);
    if (Get.isRegistered<AuthController>()) {
      await Get.find<AuthController>().updateAppLocale();
    }
  }

  static String? _rawParam(Uri link) {
    final params = link.queryParameters;
    final appLanguage = params['appLanguage'];
    if (appLanguage != null && appLanguage.isNotEmpty) return appLanguage;
    final language = params['language'];
    if (language != null && language.isNotEmpty) return language;
    return null;
  }
}
