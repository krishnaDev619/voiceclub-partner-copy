class GetCurrentOnlineDurationResponseModel {
  final num? duration;
  final num? veryHigh;
  final num? high;
  final num? low;
  final num? maxDuration;
  final num? penaltyAmount;
  final num? rewardAmount;
  final num? highRewardAmount;
  final num? reverseCutOff;
  final num? reverseCount;
  final num? incentiveCount;
  final num? incentiveCutOff;
  final List<num>? penalties;
  final List<num>? penaltyCutoffs;
  final List<num>? rewards;
  final List<num>? rewardCutoffs;
  final bool? isLeave;
  final String? rewardDate;

  GetCurrentOnlineDurationResponseModel({
    this.duration,
    this.veryHigh,
    this.high,
    this.low,
    this.maxDuration,
    this.penaltyAmount,
    this.rewardAmount,
    this.highRewardAmount,
    this.reverseCount,
    this.reverseCutOff,
    this.incentiveCount,
    this.incentiveCutOff,
    this.penalties,
    this.penaltyCutoffs,
    this.rewards,
    this.rewardCutoffs,
    this.isLeave,
    this.rewardDate,
  });

  GetCurrentOnlineDurationResponseModel.fromJson(Map<String, dynamic> json)
    : duration = json['duration'] as num?,
      veryHigh = json['very_high'] as num?,
      high = json['high'] as num?,
      low = json['low'] as num?,
      maxDuration = json['max_duration'] as num?,
      highRewardAmount = json['high_reward_amount'] as num?,
      penaltyAmount = json['penalty_amount'] as num?,
      rewardAmount = json['reward_amount'] as num?,
      reverseCutOff = json['reverse_cutoff'] as num?,
      reverseCount = json['reverse_count'] as num?,
      incentiveCount = json['incentive_count'] as num?,
      incentiveCutOff = json['incentive_cutoff'] as num?,
      penalties =
          (json['penalties'] as List?)?.map((dynamic e) => e as num).toList(),
      penaltyCutoffs =
          (json['penalty_cutoffs'] as List?)
              ?.map((dynamic e) => e as num)
              .toList(),
      rewards =
          (json['rewards'] as List?)?.map((dynamic e) => e as num).toList(),
      rewardCutoffs =
          (json['reward_cutoffs'] as List?)
              ?.map((dynamic e) => e as num)
              .toList(),
      isLeave = json['is_leave'] as bool?,
      rewardDate = json['reward_date'] as String?;

  Map<String, dynamic> toJson() => {
    'duration': duration,
    'very_high': veryHigh,
    'high': high,
    'low': low,
    'max_duration': maxDuration,
    'high_reward_amount': highRewardAmount,
    'penalty_amount': penaltyAmount,
    'reward_amount': rewardAmount,
    'reverse_cutoff': reverseCutOff,
    'reverse_count': reverseCount,
    'incentive_count': incentiveCount,
    'incentive_cutoff': incentiveCutOff,
    'is_leave': isLeave,
    'reward_date': rewardDate,
  };
}
