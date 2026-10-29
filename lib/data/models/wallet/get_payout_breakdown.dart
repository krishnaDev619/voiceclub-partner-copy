import 'package:voiceclub_partner/data/models/wallet/payout_items.dart';
import 'package:voiceclub_partner/data/models/wallet/tax.dart';

class GetPayoutBreakdownResponse {
  final List<Items>? items;
  final num? platformFee;
  final Tax? tax;
  final num? total;

  GetPayoutBreakdownResponse({
    this.items,
    this.platformFee,
    this.tax,
    this.total,
  });

  GetPayoutBreakdownResponse.fromJson(Map<String, dynamic> json)
    : items =
          (json['items'] as List?)
              ?.map((dynamic e) => Items.fromJson(e as Map<String, dynamic>))
              .toList(),
      platformFee = json['platform_fee'] as num?,
      tax =
          (json['tax'] as Map<String, dynamic>?) != null
              ? Tax.fromJson(json['tax'] as Map<String, dynamic>)
              : null,
      total = json['total'] as num?;

  Map<String, dynamic> toJson() => {
    'items': items?.map((e) => e.toJson()).toList(),
    'platform_fee': platformFee,
    'tax': tax?.toJson(),
    'total': total,
  };
}
