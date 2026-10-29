import 'package:voiceclub_partner/data/models/localization/synced_arb.dart';
import 'package:voiceclub_partner/data/models/localization/ui_language.dart';

abstract class UiLocalizationRepository {
  Future<List<UiLanguage>> getLanguages();

  /// Loads the ARB for [languageCode] when that language's last-updated
  /// time is newer than the saved copy. Otherwise returns the saved copy.
  Future<SyncedArb> syncLanguage(String languageCode);

  Future<String?> readSelectedLanguageCode();

  Future<void> saveSelectedLanguageCode(String languageCode);

  String? readLegacyToken();
}
