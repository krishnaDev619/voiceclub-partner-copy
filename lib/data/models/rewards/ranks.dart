import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

class Ranks {
  final num? rank;
  final num? rewardAmount;
  final num? value;
  final UserDataModel? user;

  Ranks({this.rank, this.rewardAmount, this.value, this.user});

  Ranks.fromJson(Map<String, dynamic> json)
    : rank = json['rank'] as num?,
      rewardAmount = json['reward_amount'] as num?,
      value = json['value'] as num?,
      user =
          (json['user'] as Map<String, dynamic>?) != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null;

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'reward_amount': rewardAmount,
    'value': value,
    'user': user?.toJson(),
  };
}
