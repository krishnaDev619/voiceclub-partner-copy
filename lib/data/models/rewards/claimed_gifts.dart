import 'package:voiceclub_partner/core/constants/enums.dart';

class ClaimedGifts {
  final int? id;
  final int? giftId;
  final int? accountId;
  final GiftType? type;
  final GiftClaimStatus? status;
  final String? claimedAt;

  ClaimedGifts({
    this.id,
    this.giftId,
    this.accountId,
    this.type,
    this.status,
    this.claimedAt,
  });

  ClaimedGifts.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      giftId = json['gift_id'] as int?,
      accountId = json['account_id'] as int?,
      type = (json['type'] as String?)?.toGiftType(),
      status = (json['status'] as String?)?.toGiftClaimStatus(),
      claimedAt = json['claimed_at'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'gift_id': giftId,
    'account_id': accountId,
    'type': type?.name,
    'status': status?.name,
    'claimed_at': claimedAt,
  };
}
