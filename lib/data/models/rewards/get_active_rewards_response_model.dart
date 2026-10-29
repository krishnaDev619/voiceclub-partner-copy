import 'package:voiceclub_partner/data/models/rewards/rewards.dart';

class GetActiveRewardsResponseModel {
  final List<Rewards>? rewards;

  GetActiveRewardsResponseModel({this.rewards});

  GetActiveRewardsResponseModel.fromJson(Map<String, dynamic> json)
    : rewards =
          (json['rewards'] as List?)
              ?.map((dynamic e) => Rewards.fromJson(e as Map<String, dynamic>))
              .toList();

  Map<String, dynamic> toJson() => {
    'rewards': rewards?.map((e) => e.toJson()).toList(),
  };
}
