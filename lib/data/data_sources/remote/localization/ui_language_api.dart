import 'package:voiceclub_partner/data/models/localization/ui_language.dart';

/// Remote contract for UI languages.
///
/// One call returns the picker list and the ARB metadata used to decide
/// whether a language file needs to be downloaded.
abstract class UiLanguageApi {
  Future<List<UiLanguage>> fetchLanguages();
}
