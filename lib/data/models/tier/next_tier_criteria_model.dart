class NextTierCriteria {
  final num? rating;
  final num? avgRingDuration;
  final num? repeatCalls;
  final num? longCalls;
  final num? callDuration;
  final num? onlineDuration;

  NextTierCriteria({
    this.rating,
    this.avgRingDuration,
    this.repeatCalls,
    this.longCalls,
    this.callDuration,
    this.onlineDuration,
  });

  NextTierCriteria.fromJson(Map<String, dynamic> json)
    : rating = json['rating'] as num?,
      avgRingDuration = json['avg_ring_duration'] as num?,
      repeatCalls = json['repeat_calls'] as num?,
      longCalls = json['long_calls'] as num?,
      callDuration = json['call_duration'] as num?,
      onlineDuration = json['online_duration'] as num?;

  Map<String, dynamic> toJson() => {
    'rating': rating,
    'avg_ring_duration': avgRingDuration,
    'repeat_calls': repeatCalls,
    'long_calls': longCalls,
    'call_duration': callDuration,
    'online_duration': onlineDuration,
  };

  num get totalSum =>
      ((rating ?? 0) +
          (avgRingDuration ?? 0) +
          (repeatCalls ?? 0) +
          (longCalls ?? 0) +
          (callDuration ?? 0) +
          (onlineDuration ?? 0));
}
