import 'package:voiceclub_partner/core/constants/enums.dart';

class Items {
  final String? title;
  final PayoutItemType? type;
  final PayoutItemSign? sign;
  final num? amount;

  Items({this.title, this.type, this.sign, this.amount});

  Items.fromJson(Map<String, dynamic> json)
    : title = json['title'] as String?,
      type = (json['type'] as String? ?? "").toPayoutItem(),
      sign = (json['sign'] as String? ?? "").toPayoutItemSign(),
      amount = json['amount'] as num?;

  Map<String, dynamic> toJson() => {
    'title': title,
    'type': type?.name,
    'sign': sign?.name,
    'amount': amount,
  };
}
