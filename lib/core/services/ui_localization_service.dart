import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/localizations/arb_refresh.dart';
import 'package:voiceclub_partner/core/localizations/locale_code.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/localization/ui_language.dart';
import 'package:voiceclub_partner/data/models/script/script.dart';
import 'package:voiceclub_partner/data/models/tutorial/journey_changes_model.dart';
import 'package:voiceclub_partner/domain/repository/ui_localization_repository.dart';
import 'package:voiceclub_partner/domain/usecases/localization/get_ui_languages.dart';
import 'package:voiceclub_partner/domain/usecases/localization/sync_ui_language.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/app_translations.dart';

/// Applies a language the languages API describes. The same response
/// carries the ARB link and last-updated time used to download the file.
class UiLocalizationService {
  UiLocalizationService(
    this._getUiLanguages,
    this._syncUiLanguage,
    this._repository,
  );

  final GetUiLanguagesUseCase _getUiLanguages;
  final SyncUiLanguageUseCase _syncUiLanguage;
  final UiLocalizationRepository _repository;

  List<UiLanguage> _languages = const [];
  String? _selectedCode;
  JourneyChangesModel? _journey;
  ScriptModel? _introAudio;

  List<UiLanguage> get languages => List.unmodifiable(_languages);

  String? get selectedCode => _selectedCode;

  /// Lessons, quizzes, and videos for the selected language.
  JourneyChangesModel? get journey => _journey;

  /// Intro recording prompt and variants for the selected language.
  ScriptModel? get introAudio => _introAudio;

  Locale get currentLocale {
    final code = _selectedCode;
    if (code == null || code.isEmpty) return bundledFallbackLocale;
    return localeFromCode(code);
  }

  /// Boot path. Loads the language list, then syncs the saved code if that
  /// code is still in the list. A failure falls back to bundled en.arb.
  Future<void> initialize() async {
    try {
      _languages = await _getUiLanguages(NoParams());
      final saved = await _repository.readSelectedLanguageCode();
      final code = _match(saved) ?? _match(_repository.readLegacyToken());
      if (code == null) return;
      final synced = await _syncUiLanguage(
        SyncUiLanguageParams(languageCode: code),
      );
      _selectedCode = code;
      _setJourney(synced.journey);
      _setIntroAudio(synced.introAudio);
      _register(code, synced.translations, updateLocale: false);
      await _repository.saveSelectedLanguageCode(code);
      await ensureBundledEnglish(updateLocale: false);
    } catch (error) {
      Logger.logMessage('UI locale init failed: $error', name: 'UI_LOCALE');
      await ensureBundledEnglish(updateLocale: false);
    }
  }

  /// Downloads or reuses the ARB for [languageCode], then switches the UI.
  Future<bool> setLanguage(String languageCode) async {
    try {
      final synced = await _syncUiLanguage(
        SyncUiLanguageParams(languageCode: languageCode),
      );
      _selectedCode = languageCode;
      _setJourney(synced.journey);
      _setIntroAudio(synced.introAudio);
      _register(languageCode, synced.translations, updateLocale: true);
      await _repository.saveSelectedLanguageCode(languageCode);
      await ensureBundledEnglish(updateLocale: true);
      return true;
    } catch (error) {
      Logger.logMessage(
        'UI locale switch failed for $languageCode: $error',
        name: 'UI_LOCALE',
      );
      await ensureBundledEnglish(updateLocale: true);
      return false;
    }
  }

  /// Maps a profile talk language (`Hindi`) to a UI code (`hi`) and loads
  /// that ARB. Used for returning partners whose [first_language] is set.
  Future<bool> applyPreferredLanguage(String? token) async {
    final value = token?.trim();
    if (value == null || value.isEmpty) return false;
    try {
      if (_languages.isEmpty) {
        _languages = await _getUiLanguages(NoParams());
      }
      final code = _match(value);
      if (code == null) {
        Logger.logMessage(
          'No UI language matches profile token "$value".',
          name: 'UI_LOCALE',
        );
        return false;
      }
      Logger.logMessage(
        'Applying preferred UI language "$value" as $code.',
        name: 'UI_LOCALE',
      );
      return setLanguage(code);
    } catch (error) {
      Logger.logMessage(
        'UI locale apply failed for $value: $error',
        name: 'UI_LOCALE',
      );
      return false;
    }
  }

  /// Resolves a previously stored token (`hi` or `Hindi`) to a listed language.
  Future<bool> applyToken(String token) => applyPreferredLanguage(token);

  /// Intro script for a talk language (`Tamil`, `Hindi`) without switching
  /// the app language. Returns null when that language has no intro script.
  Future<ScriptModel?> introAudioFor(String? token) async {
    final value = token?.trim();
    if (value == null || value.isEmpty) return _introAudio;
    try {
      if (_languages.isEmpty) {
        _languages = await _getUiLanguages(NoParams());
      }
      final code = _match(value);
      if (code == null) return null;
      if (code == _selectedCode) return _introAudio;
      final synced = await _syncUiLanguage(
        SyncUiLanguageParams(languageCode: code),
      );
      return _scriptFrom(synced.introAudio);
    } catch (error) {
      Logger.logMessage(
        'Intro audio load failed for $value: $error',
        name: 'UI_LOCALE',
      );
      return null;
    }
  }

  /// Uses bundled `en.arb` when the selected language did not supply sentences,
  /// lessons, or intro audio. Other language files are not kept as backups.
  Future<void> ensureBundledEnglish({required bool updateLocale}) async {
    final loaded = _loadedArb();
    if (loaded.isComplete) return;
    final english = await _readBundledEnglish();
    if (english == null) return;
    final merged = withEnglishBackup(loaded: loaded, english: english);
    if (!loaded.hasTranslations) {
      Logger.logMessage(
        'Language load incomplete. Using bundled en.arb.',
        name: 'UI_LOCALE',
      );
      _selectedCode = 'en';
      _setJourney(merged.journey);
      _setIntroAudio(merged.introAudio);
      _register('en', merged.translations, updateLocale: updateLocale);
      return;
    }
    Logger.logMessage(
      'Language file is missing journey or intro audio. Filling from bundled en.arb.',
      name: 'UI_LOCALE',
    );
    if (!loaded.hasJourney) _setJourney(merged.journey);
    if (!loaded.hasIntroAudio) _setIntroAudio(merged.introAudio);
  }

  LoadedArb _loadedArb() {
    final code = _selectedCode;
    final key = (code == null || code.isEmpty) ? null : translationKeyFor(code);
    final strings = key == null ? null : AppTranslation.translationsKeys[key];
    final hasJourney = _journey?.stages?.isNotEmpty ?? false;
    final hasIntro = _introAudio != null;
    return LoadedArb(
      translations: strings ?? const {},
      journey: hasJourney ? const {'loaded': true} : null,
      introAudio: hasIntro ? const {'loaded': true} : null,
    );
  }

  Future<LoadedArb?> _readBundledEnglish() async {
    try {
      final raw = await rootBundle.loadString('assets/i18n/en.arb');
      final parsed = parseArb(jsonDecode(raw) as Map<String, dynamic>);
      return LoadedArb(
        translations: parsed.translations,
        journey: parsed.journey,
        introAudio: parsed.introAudio,
      );
    } catch (error) {
      Logger.logMessage(
        'Bundled en.arb could not be read: $error',
        name: 'UI_LOCALE',
      );
      return null;
    }
  }

  void _setJourney(Map<String, dynamic>? content) {
    if (content == null || content.isEmpty) {
      _journey = null;
      return;
    }
    _journey = JourneyChangesModel.fromJson(content);
  }

  void _setIntroAudio(Map<String, dynamic>? content) {
    _introAudio = _scriptFrom(content);
  }

  ScriptModel? _scriptFrom(Map<String, dynamic>? content) {
    if (content == null || content.isEmpty) return null;
    final model = ScriptModel.fromJson(content);
    final hasVariants = model.variants?.isNotEmpty ?? false;
    final hasPrompt = model.prompt?.trim().isNotEmpty ?? false;
    return (hasVariants || hasPrompt) ? model : null;
  }

  String? _match(String? token) {
    for (final language in _languages) {
      if (language.matchesToken(token)) return language.code;
    }
    return null;
  }

  void _register(
    String languageCode,
    Map<String, String> translations, {
    required bool updateLocale,
  }) {
    if (translations.isEmpty) {
      if (updateLocale) Get.updateLocale(localeFromCode(languageCode));
      return;
    }
    final key = translationKeyFor(languageCode);
    AppTranslation.addLocale(key, translations);
    if (!updateLocale) return;
    Get.addTranslations({key: translations});
    Get.updateLocale(localeFromCode(languageCode));
  }
}
