import 'package:voiceclub_partner/data/models/chat/preset.dart';

class PresetGroup {
  final String? name;
  final List<Preset>? presets;

  PresetGroup({this.name, this.presets});

  PresetGroup.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String?,
      presets =
          (json['presets'] as List?)
              ?.map((dynamic e) => Preset.fromJson(e as Map<String, dynamic>))
              .toList();

  Map<String, dynamic> toJson() => {
    'name': name,
    'presets': presets?.map((e) => e.toJson()).toList(),
  };
}
