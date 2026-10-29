import 'package:voiceclub_partner/core/constants/enums.dart';

class Rewards {
  final int? rewardId;
  final String? imageUrl;
  final String? name;
  final RewardType? type;
  final String? description;
  final String? colorCode;
  final String? colorCodeDark;
  final String? colorCodeSecondary;
  final String? unit;
  final DateTime? endsOn;
  final List<RewardAudios>? rewardAudios;

  Rewards({
    this.rewardId,
    this.imageUrl,
    this.name,
    this.type,
    this.description,
    this.colorCode,
    this.colorCodeDark,
    this.colorCodeSecondary,
    this.unit,
    this.endsOn,
    this.rewardAudios,
  });

  Rewards.fromJson(Map<String, dynamic> json)
    : rewardId = json['id'] as int?,
      imageUrl = json['image_url'] as String?,
      name = json['name'] as String?,
      type = (json['type'] as String? ?? "").toRewardType(),
      description = json['description'] as String?,
      colorCode = json['color_code'] as String?,
      colorCodeDark = json['color_code_dark'] as String?,
      colorCodeSecondary = json['color_code_secondary'] as String?,
      unit = json['unit'] as String?,
      endsOn = (json['ends_on'] as String? ?? "").toDateTime(),
      rewardAudios =
          (json['reward_audios'] as List?)
              ?.map(
                (dynamic e) => RewardAudios.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'id': rewardId,
    'image_url': imageUrl,
    'name': name,
    'type': type?.name,
    'description': description,
    'color_code': colorCode,
    'color_code_dark': colorCodeDark,
    'color_code_secondary': colorCodeSecondary,
    'unit': unit,
    'ends_on': endsOn,
    'reward_audios': rewardAudios?.map((e) => e.toJson()).toList(),
  };
}

class RewardAudios {
  final String? language;
  final String? audioUrl;

  RewardAudios({this.language, this.audioUrl});

  RewardAudios.fromJson(Map<String, dynamic> json)
    : language = json['language'] as String?,
      audioUrl = json['audio_url'] as String?;

  Map<String, dynamic> toJson() => {
    'language': language,
    'audio_url': audioUrl,
  };
}
