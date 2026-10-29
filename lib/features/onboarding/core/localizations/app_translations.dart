import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/en_locale.dart';

abstract class AppTranslation {
  static Map<String, Map<String, String>> translationsKeys = {"en_US": enUS};

  static void addLocale(String code, Map<String, String> strings) {
    translationsKeys[code] = strings;
  }
}
