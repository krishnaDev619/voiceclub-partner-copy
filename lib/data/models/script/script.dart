class ScriptModel {
  final String? prompt;
  final List<ScriptVariant>? variants;

  ScriptModel({this.prompt, this.variants});

  ScriptModel.fromJson(Map<String, dynamic> json)
    : prompt = json['prompt'] as String?,
      variants =
          (json['variants'] as List?)
              ?.map(
                (dynamic e) =>
                    ScriptVariant.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'variants': variants?.map((e) => e.toJson()).toList(),
  };
}

class ScriptVariant {
  final String? primaryVariant;
  final String? secondaryVariant;
  final String? audioUrl;

  ScriptVariant({this.primaryVariant, this.secondaryVariant, this.audioUrl});

  ScriptVariant.fromJson(Map<String, dynamic> json)
    : primaryVariant = json['primary_variant'] as String?,
      secondaryVariant = json['secondary_variant'] as String?,
      audioUrl = json['audio_url'] as String?;

  Map<String, dynamic> toJson() => {
    'primary_variant': primaryVariant,
    'secondary_variant': secondaryVariant,
    'audio_url': audioUrl,
  };
}
