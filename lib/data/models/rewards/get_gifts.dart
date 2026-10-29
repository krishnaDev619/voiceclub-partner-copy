import 'package:voiceclub_partner/data/models/rewards/claimed_gifts.dart';
import 'package:voiceclub_partner/data/models/rewards/gifts.dart';

class GetGiftsResponse {
  final List<ClaimedGifts>? claimedGifts;
  final List<RewardGift>? gifts;

  GetGiftsResponse({this.claimedGifts, this.gifts});

  GetGiftsResponse.fromJson(Map<String, dynamic> json)
    : claimedGifts =
          (json['claimed_gifts'] as List?)
              ?.map(
                (dynamic e) => ClaimedGifts.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      gifts =
          (json['gifts'] as List?)
              ?.map(
                (dynamic e) => RewardGift.fromJson(e as Map<String, dynamic>),
              )
              .toList();

  Map<String, dynamic> toJson() => {
    'claimed_gifts': claimedGifts?.map((e) => e.toJson()).toList(),
    'gifts': gifts?.map((e) => e.toJson()).toList(),
  };
}
