import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/metrics/cutoffs.dart';

class ScoreModel {
  final String? name;
  final MetricsCutoffTag? tag;
  final num? value;
  final num? score;
  final String? label;
  final String? units;
  final num? maxValue;
  final List<ScoreCutoff>? cutoffs;
  final String? videoUrl;
  final String? iconUrl;

  ScoreModel({
    this.name,
    this.tag,
    this.value,
    this.score,
    this.label,
    this.units,
    this.maxValue,
    this.cutoffs,
    this.videoUrl,
    this.iconUrl,
  });

  ScoreModel.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String?,
      tag = (json['tag'] as String?)?.toMetricsCutoffTag(),
      value = json['value'] as num?,
      score = json['score'] as num?,
      label = json['label'] as String?,
      units = json['units'] as String?,
      maxValue = json['max_value'] as num?,
      cutoffs =
          (json['cutoffs'] as List?)
              ?.map(
                (dynamic e) => ScoreCutoff.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      videoUrl = json['video_url'] as String?,
      iconUrl = json['icon_url'] as String?;

  Map<String, dynamic> toJson() => {
    'name': name,
    'tag': tag?.name,
    'value': value,
    'score': score,
    'label': label,
    'units': units,
    'max_value': maxValue,
    'cutoffs': cutoffs?.map((e) => e.toJson()).toList(),
    'video_url': videoUrl,
    'icon_url': iconUrl,
  };
}
