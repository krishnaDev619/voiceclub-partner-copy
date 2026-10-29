class RewardsStatsResponse {
  final OnlineDuration? onlineDuration;
  final IncentiveCalls? incentiveCalls;
  final IncentiveCalls? reverseCalls;
  final IncentiveCalls? chatReceived;
  final bool? isLeave;
  final String? rewardDate;

  RewardsStatsResponse({
    this.onlineDuration,
    this.incentiveCalls,
    this.reverseCalls,
    this.chatReceived,
    this.isLeave,
    this.rewardDate,
  });

  RewardsStatsResponse.fromJson(Map<String, dynamic> json)
    : onlineDuration =
          (json['online_duration'] as Map<String, dynamic>?) != null
              ? OnlineDuration.fromJson(
                json['online_duration'] as Map<String, dynamic>,
              )
              : null,
      incentiveCalls =
          (json['incentive_calls'] as Map<String, dynamic>?) != null
              ? IncentiveCalls.fromJson(
                json['incentive_calls'] as Map<String, dynamic>,
              )
              : null,
      reverseCalls =
          (json['reverse_calls'] as Map<String, dynamic>?) != null
              ? IncentiveCalls.fromJson(
                json['reverse_calls'] as Map<String, dynamic>,
              )
              : null,
      chatReceived =
          (json['chat_received'] as Map<String, dynamic>?) != null
              ? IncentiveCalls.fromJson(
                json['chat_received'] as Map<String, dynamic>,
              )
              : null,
      isLeave = json['is_leave'] as bool?,
      rewardDate = json['reward_date'] as String?;

  Map<String, dynamic> toJson() => {
    'online_duration': onlineDuration?.toJson(),
    'incentive_calls': incentiveCalls?.toJson(),
    'reverse_calls': reverseCalls?.toJson(),
    'chat_received': chatReceived?.toJson(),
    'is_leave': isLeave,
    'reward_date': rewardDate,
  };
}

class OnlineDuration {
  final num? currentHours;
  final String? status;
  final num? amount;
  final num? penaltyThreshold;
  final num? rewardThreshold;
  final num? penaltyAmount;
  final num? rewardAmount;
  final String? achievedThreshold;

  OnlineDuration({
    this.currentHours,
    this.status,
    this.amount,
    this.penaltyThreshold,
    this.rewardThreshold,
    this.penaltyAmount,
    this.rewardAmount,
    this.achievedThreshold,
  });

  OnlineDuration.fromJson(Map<String, dynamic> json)
    : currentHours = json['current_hours'] as num?,
      status = json['status'] as String?,
      amount = json['amount'] as num?,
      penaltyThreshold = json['penalty_threshold'] as num?,
      rewardThreshold = json['reward_threshold'] as num?,
      penaltyAmount = json['penalty_amount'] as num?,
      rewardAmount = json['reward_amount'] as num?,
      achievedThreshold = json['achieved_threshold'] as String?;

  Map<String, dynamic> toJson() => {
    'current_hours': currentHours,
    'status': status,
    'amount': amount,
    'penalty_threshold': penaltyThreshold,
    'reward_threshold': rewardThreshold,
    'penalty_amount': penaltyAmount,
    'reward_amount': rewardAmount,
    'achieved_threshold': achievedThreshold,
  };
}

class IncentiveCalls {
  final int? currentCount;
  final String? status;
  final num? amount;
  final List<Thresholds>? thresholds;

  IncentiveCalls({
    this.currentCount,
    this.status,
    this.amount,
    this.thresholds,
  });

  IncentiveCalls.fromJson(Map<String, dynamic> json)
    : currentCount = json['current_count'] as int?,
      status = json['status'] as String?,
      amount = json['amount'] as num?,
      thresholds =
          (json['thresholds'] as List?)
              ?.map(
                (dynamic e) => Thresholds.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'current_count': currentCount,
    'status': status,
    'amount': amount,
    'thresholds': thresholds?.map((e) => e.toJson()).toList(),
  };
}

class Thresholds {
  final int? count;
  final num? amount;

  Thresholds({this.count, this.amount});

  Thresholds.fromJson(Map<String, dynamic> json)
    : count = json['count'] as int?,
      amount = json['amount'] as num?;

  Map<String, dynamic> toJson() => {'count': count, 'amount': amount};
}
