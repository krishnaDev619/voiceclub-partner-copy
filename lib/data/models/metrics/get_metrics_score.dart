import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/metrics/score_model.dart';

class GetMetricsScoreResponse {
  final ScoreModel? aggregate;
  final List<ScoreModel>? metrics;
  final List<MetricsScoreHistoryItem>? history;
  final String? updatedAt;
  final num? firingCutoff;

  GetMetricsScoreResponse({
    this.aggregate,
    this.metrics,
    this.history,
    this.updatedAt,
    this.firingCutoff,
  });

  GetMetricsScoreResponse.fromJson(Map<String, dynamic> json)
    : aggregate =
          (json['aggregate'] as Map<String, dynamic>?) != null
              ? ScoreModel.fromJson(json['aggregate'] as Map<String, dynamic>)
              : null,
      metrics =
          (json['metrics'] as List?)
              ?.map(
                (dynamic e) => ScoreModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      history =
          (json['history'] as List?)
              ?.map(
                (dynamic e) =>
                    MetricsScoreHistoryItem.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      updatedAt = json['updated_at'] as String?,
      firingCutoff = json['firing_cutoff'] as num?;

  Map<String, dynamic> toJson() => {
    'aggregate': aggregate?.toJson(),
    'metrics': metrics?.map((e) => e.toJson()).toList(),
    'history': history?.map((e) => e.toJson()).toList(),
    'updated_at': updatedAt,
    'firing_cutoff': firingCutoff,
  };

  Map<String, num?> get scoreValues {
    if (metrics == null) return {};
    return {
      for (final metric in metrics!)
        if (metric.name != null) metric.name!: metric.score,
    };
  }
}

class MetricsScoreHistoryItem {
  final String? date;
  final num? scoreAggregate;
  final MetricsCutoffTag? tagAggregate;

  MetricsScoreHistoryItem({this.date, this.scoreAggregate, this.tagAggregate});

  MetricsScoreHistoryItem.fromJson(Map<String, dynamic> json)
    : date = json['date'] as String?,
      scoreAggregate = json['score_aggregate'] as num?,
      tagAggregate = (json['tag_aggregate'] as String?)?.toMetricsCutoffTag();

  Map<String, dynamic> toJson() => {
    'date': date,
    'score_aggregate': scoreAggregate,
    'tag_aggregate': tagAggregate?.name,
  };

  /// Backward compatibility: same as [scoreAggregate].
  num? get totalScore => scoreAggregate;

  /// Backward compatibility: same as [tagAggregate].
  MetricsCutoffTag? get tag => tagAggregate;
}
