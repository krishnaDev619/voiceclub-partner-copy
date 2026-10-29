class GetRewardsConfig {
  final String? peakHourRewardStartTime;
  final String? peakHourRewardEndTime;
  final int? callDurationThreshold;

  GetRewardsConfig({
    this.peakHourRewardStartTime,
    this.peakHourRewardEndTime,
    this.callDurationThreshold,
  });

  GetRewardsConfig.fromJson(Map<String, dynamic> json)
    : peakHourRewardStartTime = json['peak_hour_reward_start_time'] as String?,
      peakHourRewardEndTime = json['peak_hour_reward_end_time'] as String?,
      callDurationThreshold = json['call_duration_threshold'] as int?;

  Map<String, dynamic> toJson() => {
    'peak_hour_reward_start_time': peakHourRewardStartTime,
    'peak_hour_reward_end_time': peakHourRewardEndTime,
    'call_duration_threshold': callDurationThreshold,
  };
}
