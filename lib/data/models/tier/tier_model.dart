import 'package:voiceclub_partner/core/constants/enums.dart';

class TierModel {
  final int? id;
  final num? revenueShare;
  final SupplyTier? tier;
  final num? rating;
  final num? avgRingDuration;
  final num? repeatCalls;
  final num? longCalls;
  final num? callDuration;
  final num? onlineDuration;

  TierModel({
    this.id,
    this.revenueShare,
    this.tier,
    this.rating,
    this.avgRingDuration,
    this.repeatCalls,
    this.longCalls,
    this.callDuration,
    this.onlineDuration,
  });

  TierModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      revenueShare = json['revenue_share'] as num?,
      rating = json['rating'] as num?,
      avgRingDuration = json['avg_ring_duration'] as num?,
      repeatCalls = json['repeat_calls'] as num?,
      longCalls = json['long_calls'] as num?,
      callDuration = json['call_duration'] as num?,
      onlineDuration = json['online_duration'] as num?,
      tier = ((json['name'] as String?) ?? '').toSupplyTier();

  Map<String, dynamic> toJson() => {
    'id': id,
    'revenue_share': revenueShare,
    'name': tier?.name,
    'rating': rating,
    'avg_ring_duration': avgRingDuration,
    'repeat_calls': repeatCalls,
    'long_calls': longCalls,
    'call_duration': callDuration,
    'online_duration': onlineDuration,
  };
}
