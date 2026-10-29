class SyncedArb {
  const SyncedArb({
    required this.languageCode,
    required this.translations,
    this.journey,
    this.introAudio,
  });

  final String languageCode;
  final Map<String, String> translations;
  final Map<String, dynamic>? journey;
  final Map<String, dynamic>? introAudio;
}
