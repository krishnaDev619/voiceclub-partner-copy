import 'package:voiceclub_partner/core/constants/enums.dart';

class AudioLengthLimits {
  final int? limitInSecs;
  final ChatTier? tier;

  AudioLengthLimits({this.limitInSecs, this.tier});

  AudioLengthLimits.fromJson(Map<String, dynamic> json)
    : limitInSecs = json['limit_in_secs'] as int?,
      tier = (json['tier'] as String? ?? '').toChatTier();

  Map<String, dynamic> toJson() => {
    'limit_in_secs': limitInSecs,
    'tier': tier.toString(),
  };
}
