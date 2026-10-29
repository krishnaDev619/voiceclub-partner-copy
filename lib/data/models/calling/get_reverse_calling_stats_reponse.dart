class GetReverseCallingStatsResponseModel {
  final int? count;
  final int? maxCount;
  final int? duration;
  final int? totalCallDuration;
  final bool? isCallAllowed;
  final bool? toReceiveReverseCall;
  final String? reason;
  final int? rechargedDuration;
  final int? cutoffDuration;

  GetReverseCallingStatsResponseModel({
    this.count,
    this.duration,
    this.totalCallDuration,
    this.isCallAllowed,
    this.toReceiveReverseCall,
    this.reason,
    this.maxCount,
    this.rechargedDuration,
    this.cutoffDuration,
  });

  GetReverseCallingStatsResponseModel.fromJson(Map<String, dynamic> json)
    : count = json['count'] as int?,
      maxCount = json['max_count'] as int?,
      duration = json['duration'] as int?,
      totalCallDuration = json['total_call_duration'] as int?,
      isCallAllowed = json['is_call_allowed'] as bool?,
      toReceiveReverseCall = json['to_receive_reverse_call'] as bool?,
      reason = json['reason'] as String?,
      rechargedDuration = json['recharged_duration'] as int?,
      cutoffDuration = json['cutoff_duration'] as int?;

  Map<String, dynamic> toJson() => {
    'count': count,
    'max_count': maxCount,
    'duration': duration,
    'total_call_duration': totalCallDuration,
    'is_call_allowed': isCallAllowed,
    'to_receive_reverse_call': toReceiveReverseCall,
    'reason': reason,
    'recharged_duration': rechargedDuration,
    'cutoff_duration': cutoffDuration,
  };

  bool get hasRecharged => rechargedDuration != null && rechargedDuration! > 0;

  bool get hasPassedCriteria =>
      totalCallDuration != null &&
      cutoffDuration != null &&
      totalCallDuration! > cutoffDuration!;

  /// Returns the difference between totalCallDuration and cutoffDuration
  /// formatted as "Xm Ys" (minutes and seconds).
  /// Returns the remaining duration till the cutoff duration
  String get remainingDurationString {
    final int total = totalCallDuration ?? 0;
    final int cutoff = cutoffDuration ?? 0;
    int diff = cutoff - total;
    if (diff < 0) diff = 0;
    final int minutes = diff ~/ 60;
    final int seconds = diff % 60;
    return "${minutes}m ${seconds}s";
  }
}
