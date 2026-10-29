class Criteria {
  final num? rewardAmount;
  final num? cutoffValue;
  final num? cutoffValueRed;
  final num? cutoffValueGreen;
  final num? cutoffValueYellow;

  Criteria({
    this.rewardAmount,
    this.cutoffValue,
    this.cutoffValueRed,
    this.cutoffValueGreen,
    this.cutoffValueYellow,
  });

  Criteria.fromJson(Map<String, dynamic> json)
    : rewardAmount = json['reward_amount'] as num?,
      cutoffValue = json['cutoff_value'] as num?,
      cutoffValueRed = json['cutoff_value_red'] as num?,
      cutoffValueGreen = json['cutoff_value_green'] as num?,
      cutoffValueYellow = json['cutoff_value_yellow'] as num?;

  Map<String, dynamic> toJson() => {
    'reward_amount': rewardAmount,
    'cutoff_value': cutoffValue,
    'cutoff_value_red': cutoffValueRed,
    'cutoff_value_green': cutoffValueGreen,
    'cutoff_value_yellow': cutoffValueYellow,
  };
}
