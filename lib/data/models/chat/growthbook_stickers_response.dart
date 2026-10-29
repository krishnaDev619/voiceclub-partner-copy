import 'package:voiceclub_partner/data/models/chat/gift_data.dart';

class GrowthbookStickersResponseModel {
  final List<GiftData>? stickers;

  GrowthbookStickersResponseModel({this.stickers});

  GrowthbookStickersResponseModel.fromJson(Map<String, dynamic> json)
    : stickers =
          (json['stickers'] as List?)
              ?.map((dynamic e) => GiftData.fromJson(e as Map<String, dynamic>))
              .toList();

  Map<String, dynamic> toJson() => {
    'stickers': stickers?.map((e) => e.toJson()).toList(),
  };
}
