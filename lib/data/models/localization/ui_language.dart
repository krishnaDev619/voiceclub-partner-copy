class UiLanguage {
  const UiLanguage({
    required this.code,
    required this.name,
    this.icon,
    this.appLanguage,
    this.arbUrl,
    this.lastUpdated,
  });

  final String code;
  final String name;
  final String? icon;

  /// Value the existing profile and video flow already stores.
  /// The app forwards it and does not interpret it.
  final String? appLanguage;
  final String? arbUrl;
  final String? lastUpdated;

  factory UiLanguage.fromJson(Map<String, dynamic> json) {
    return UiLanguage(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: _nonEmpty(json['icon']),
      appLanguage: _nonEmpty(json['app_language']),
      arbUrl: _nonEmpty(json['arb_url']),
      lastUpdated: _nonEmpty(json['last_updated']),
    );
  }

  /// Profile talk language is `Hindi`; UI codes are `hi`. Match either.
  bool matchesToken(String? token) {
    final value = token?.trim().toLowerCase() ?? '';
    if (value.isEmpty || value == 'empty') return false;
    return code.toLowerCase() == value ||
        name.toLowerCase() == value ||
        appLanguage?.toLowerCase() == value;
  }
}

String? _nonEmpty(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

class UiLanguagesResponse {
  const UiLanguagesResponse({this.languages = const []});

  final List<UiLanguage> languages;

  factory UiLanguagesResponse.fromJson(Map<String, dynamic> json) {
    final rows = json['languages'] as List<dynamic>? ?? const [];
    return UiLanguagesResponse(
      languages:
          rows
              .whereType<Map<String, dynamic>>()
              .map(UiLanguage.fromJson)
              .toList(),
    );
  }
}
