class PayoutCountResponse {
  final int? payoutCount;
  final bool? isAchievementAllowed;

  PayoutCountResponse({this.payoutCount, this.isAchievementAllowed});

  PayoutCountResponse.fromJson(Map<String, dynamic> json)
    : payoutCount = json['payout_count'] as int?,
      isAchievementAllowed = json['is_achievement_allowed'] as bool?;

  Map<String, dynamic> toJson() => {
    'payout_count': payoutCount,
    'is_achievement_allowed': isAchievementAllowed,
  };
}
