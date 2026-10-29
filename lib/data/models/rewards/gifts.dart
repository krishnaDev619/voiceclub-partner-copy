import 'package:voiceclub_partner/core/constants/enums.dart';

class RewardGift {
  final int? id;
  final String? title;
  final num? targetEarnings;
  final String? imagePath;
  final GiftType? type;
  final num? cashAmount;

  RewardGift({
    this.id,
    this.title,
    this.targetEarnings,
    this.imagePath,
    this.type,
    this.cashAmount,
  });

  RewardGift.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      title = json['title'] as String?,
      targetEarnings = json['target_earnings'] as num?,
      imagePath = json['image_path'] as String?,
      type = (json['type'] as String?)?.toGiftType(),
      cashAmount = json['cash_amount'] as num?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'target_earnings': targetEarnings,
    'image_path': imagePath,
    'type': type?.name,
    'cash_amount': cashAmount,
  };
}
