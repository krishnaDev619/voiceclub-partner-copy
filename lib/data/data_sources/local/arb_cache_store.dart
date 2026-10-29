import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CachedArb {
  const CachedArb({
    required this.translations,
    required this.lastUpdated,
    this.journey,
    this.introAudio,
  });

  final Map<String, String> translations;
  final String? lastUpdated;
  final Map<String, dynamic>? journey;
  final Map<String, dynamic>? introAudio;
}

/// Saves the chosen language code and one ARB snapshot per code.
class ArbCacheStore {
  ArbCacheStore(this._prefs);

  final SharedPreferences _prefs;

  static const _selectedKey = 'ui_language_code';
  static const _legacyKey = 'appLocale';

  String? readSelectedCode() => _prefs.getString(_selectedKey);

  /// Token written by the previous language picker (`Hindi`, `Tamil`, …).
  String? readLegacyToken() => _prefs.getString(_legacyKey);

  Future<void> saveSelectedCode(String languageCode) {
    return _prefs.setString(_selectedKey, languageCode);
  }

  CachedArb? read(String languageCode) {
    final raw = _prefs.getString(_cacheKey(languageCode));
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final storedTranslations = decoded['translations'];
    final flat = storedTranslations is Map ? storedTranslations : decoded;
    final storedJourney = decoded['journey'];
    final storedIntro = decoded['introAudio'];
    return CachedArb(
      translations: Map<String, dynamic>.from(
        flat,
      ).map((key, value) => MapEntry(key, value.toString())),
      lastUpdated: _prefs.getString(_stampKey(languageCode)),
      journey:
          storedJourney is Map
              ? Map<String, dynamic>.from(storedJourney)
              : null,
      introAudio:
          storedIntro is Map ? Map<String, dynamic>.from(storedIntro) : null,
    );
  }

  Future<void> write({
    required String languageCode,
    required Map<String, String> translations,
    required String lastUpdated,
    Map<String, dynamic>? journey,
    Map<String, dynamic>? introAudio,
  }) async {
    await _prefs.setString(
      _cacheKey(languageCode),
      jsonEncode({
        'translations': translations,
        'journey': journey,
        'introAudio': introAudio,
      }),
    );
    await _prefs.setString(_stampKey(languageCode), lastUpdated);
  }

  String _cacheKey(String languageCode) => 'arb_cache_$languageCode';

  String _stampKey(String languageCode) => 'arb_last_updated_$languageCode';
}
