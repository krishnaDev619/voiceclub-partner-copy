import 'package:voiceclub_partner/core/constants/enums.dart';

class ScoreCutoff {
  final MetricsCutoffTag? tag;
  final num? percentage;

  ScoreCutoff({this.tag, this.percentage});

  ScoreCutoff.fromJson(Map<String, dynamic> json)
    : tag = (json['tag'] as String?)?.toMetricsCutoffTag(),
      percentage = json['percentage'] as num?;

  Map<String, dynamic> toJson() => {'tag': tag?.name, 'percentage': percentage};
}
