import 'dart:convert';

import 'package:voiceclub_partner/core/localizations/arb_refresh.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/data_sources/local/arb_cache_store.dart';
import 'package:voiceclub_partner/data/data_sources/remote/localization/arb_file_client.dart';
import 'package:voiceclub_partner/data/data_sources/remote/localization/ui_language_api.dart';
import 'package:voiceclub_partner/data/models/localization/synced_arb.dart';
import 'package:voiceclub_partner/data/models/localization/ui_language.dart';
import 'package:voiceclub_partner/domain/repository/ui_localization_repository.dart';

class UiLocalizationRepositoryImpl implements UiLocalizationRepository {
  UiLocalizationRepositoryImpl(this._api, this._cache, this._files);

  final UiLanguageApi _api;
  final ArbCacheStore _cache;
  final ArbFileClient _files;

  List<UiLanguage> _languages = const [];

  @override
  Future<List<UiLanguage>> getLanguages() async {
    try {
      _languages = await _api.fetchLanguages();
      Logger.logMessage(
        'Loaded ${_languages.length} UI languages.',
        name: 'UI_LOCALE',
      );
      return _languages;
    } catch (error) {
      Logger.logMessage('UI languages fetch failed: $error', name: 'UI_LOCALE');
      rethrow;
    }
  }

  @override
  Future<String?> readSelectedLanguageCode() async => _cache.readSelectedCode();

  @override
  Future<void> saveSelectedLanguageCode(String languageCode) {
    return _cache.saveSelectedCode(languageCode);
  }

  @override
  String? readLegacyToken() => _cache.readLegacyToken();

  @override
  Future<SyncedArb> syncLanguage(String languageCode) async {
    final language = await _languageFor(languageCode);
    final cached = _cache.read(languageCode);
    final url = language.arbUrl?.trim();
    final source =
        (url == null || url.isEmpty)
            ? 'https://mock.local/i18n/$languageCode.arb'
            : url;

    final decision = decideArbRefresh(
      cachedLastModified: cached?.lastUpdated,
      remoteLastModified: language.lastUpdated,
      hasCachedTranslations: cached != null && cached.translations.isNotEmpty,
    );
    if (decision == ArbRefreshDecision.useCache && cached != null) {
      Logger.logMessage(
        'ARB for $languageCode unchanged (${language.lastUpdated}). Using saved copy.',
        name: 'UI_LOCALE',
      );
      return SyncedArb(
        languageCode: languageCode,
        translations: cached.translations,
        journey: cached.journey,
        introAudio: cached.introAudio,
      );
    }

    Logger.logMessage(
      'ARB for $languageCode last updated ${language.lastUpdated}. Downloading.',
      name: 'UI_LOCALE',
    );
    late final String raw;
    try {
      raw = await _files.read(source);
    } catch (error) {
      Logger.logMessage(
        'ARB download failed for $languageCode: $error',
        name: 'UI_LOCALE',
      );
      return SyncedArb(
        languageCode: languageCode,
        translations: cached?.translations ?? const {},
        journey: cached?.journey,
        introAudio: cached?.introAudio,
      );
    }
    final parsed = parseArb(jsonDecode(raw) as Map<String, dynamic>);
    final lastUpdated = language.lastUpdated ?? parsed.lastModified ?? '';
    await _cache.write(
      languageCode: languageCode,
      translations: parsed.translations,
      lastUpdated: lastUpdated,
      journey: parsed.journey,
      introAudio: parsed.introAudio,
    );
    return SyncedArb(
      languageCode: languageCode,
      translations: parsed.translations,
      journey: parsed.journey,
      introAudio: parsed.introAudio,
    );
  }

  Future<UiLanguage> _languageFor(String languageCode) async {
    var language = _lookup(languageCode);
    if (language == null) {
      await getLanguages();
      language = _lookup(languageCode);
    }
    if (language == null) {
      throw StateError('No language for $languageCode');
    }
    return language;
  }

  UiLanguage? _lookup(String languageCode) {
    for (final language in _languages) {
      if (language.code == languageCode) return language;
    }
    return null;
  }
}
