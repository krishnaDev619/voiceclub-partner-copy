enum ArbRefreshDecision { useCache, download }

/// Sentences plus the structured blocks a screen reads from an ARB.
class LoadedArb {
  const LoadedArb({
    this.translations = const {},
    this.journey,
    this.introAudio,
  });

  final Map<String, String> translations;
  final Map<String, dynamic>? journey;
  final Map<String, dynamic>? introAudio;

  bool get hasTranslations => translations.isNotEmpty;
  bool get hasJourney => journey != null && journey!.isNotEmpty;
  bool get hasIntroAudio => introAudio != null && introAudio!.isNotEmpty;
  bool get isComplete => hasTranslations && hasJourney && hasIntroAudio;
}

/// Fills whatever [loaded] is missing from the bundled English ARB.
///
/// Loaded sentences stay in place. English is used only for a block the
/// selected language did not supply.
LoadedArb withEnglishBackup({
  required LoadedArb loaded,
  required LoadedArb english,
}) {
  if (loaded.isComplete) return loaded;
  return LoadedArb(
    translations:
        loaded.hasTranslations ? loaded.translations : english.translations,
    journey: loaded.hasJourney ? loaded.journey : english.journey,
    introAudio: loaded.hasIntroAudio ? loaded.introAudio : english.introAudio,
  );
}

class ParsedArb {
  const ParsedArb({
    required this.translations,
    this.lastModified,
    this.journey,
    this.introAudio,
  });

  final Map<String, String> translations;
  final String? lastModified;

  /// Old-journey lessons, quizzes, and videos. Kept as structured data so
  /// lesson lists are not flattened into translation keys.
  final Map<String, dynamic>? journey;

  /// Intro recording prompt and variants for this language file.
  final Map<String, dynamic>? introAudio;
}

/// Drops editor notes and ARB metadata, and keeps sentences.
///
/// A file may group sentences under Onboarding, Journey, and Modules.
/// Those group names are for people editing the file. The app only keeps
/// the sentence itself.
ParsedArb parseArb(Map<String, dynamic> json) {
  String? lastModified;
  final translations = <String, String>{};
  _collectSentences(json, translations, (value) => lastModified = value);
  final introAudio = _introAudio(json);
  _collectIntroAudioTranslationKeys(introAudio, translations);
  return ParsedArb(
    translations: translations,
    lastModified: lastModified,
    journey: _journeyLessons(json),
    introAudio: introAudio,
  );
}

/// IntroAudio holds structured script data, but these URL keys are also
/// exposed as flat translations for [URLConstants].
void _collectIntroAudioTranslationKeys(
  Map<String, dynamic>? introAudio,
  Map<String, String> translations,
) {
  if (introAudio == null) return;
  for (final key in ['introAudioVideo', 'defaultSampleAudio']) {
    final value = introAudio[key];
    if (value is String) {
      translations[key] = value;
    }
  }
}

Map<String, dynamic>? _introAudio(Map<String, dynamic> json) {
  final intro = json['IntroAudio'];
  if (intro is! Map) return null;
  return Map<String, dynamic>.from(intro);
}

Map<String, dynamic>? _journeyLessons(Map<String, dynamic> json) {
  final journey = json['Journey'];
  if (journey is! Map) return null;
  final lessons = journey['Lessons'];
  if (lessons is! Map) return null;
  return Map<String, dynamic>.from(lessons);
}

void _collectSentences(
  Map<String, dynamic> json,
  Map<String, String> translations,
  void Function(String value) onLastModified,
) {
  for (final entry in json.entries) {
    if (entry.key == '@@last_modified') {
      onLastModified(entry.value?.toString() ?? '');
      continue;
    }
    if (entry.key.startsWith('@') || entry.key.startsWith('_')) continue;
    if (entry.key == 'Lessons' || entry.key == 'IntroAudio') continue;
    final value = entry.value;
    if (value is String) {
      translations[entry.key] = value;
      continue;
    }
    if (value is Map) {
      _collectSentences(
        Map<String, dynamic>.from(value),
        translations,
        onLastModified,
      );
    }
  }
}

/// [remoteLastModified] is `last_updated` from the languages API.
/// The file is downloaded only when that stamp is newer than the one saved
/// on the phone, or when there is no saved copy.
ArbRefreshDecision decideArbRefresh({
  required String? cachedLastModified,
  required String? remoteLastModified,
  required bool hasCachedTranslations,
}) {
  if (!hasCachedTranslations ||
      cachedLastModified == null ||
      cachedLastModified.isEmpty) {
    return ArbRefreshDecision.download;
  }
  if (remoteLastModified == null || remoteLastModified.isEmpty) {
    return ArbRefreshDecision.useCache;
  }
  final cached = DateTime.tryParse(cachedLastModified)?.toUtc();
  final remote = DateTime.tryParse(remoteLastModified)?.toUtc();
  if (cached == null || remote == null) {
    return ArbRefreshDecision.download;
  }
  if (remote.isAfter(cached)) {
    return ArbRefreshDecision.download;
  }
  return ArbRefreshDecision.useCache;
}
