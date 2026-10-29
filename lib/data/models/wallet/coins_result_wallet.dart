import 'package:voiceclub_partner/core/constants/enums.dart';

class CoinsResultWallet {
  final int? iD;
  final String? title;
  final String? subtitle;
  final int? amount;
  final PayoutItemSign? sign;
  final TransactionType? type;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  CoinsResultWallet({
    this.iD,
    this.title,
    this.subtitle,
    this.amount,
    this.sign,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  CoinsResultWallet.fromJson(Map<String, dynamic> json)
    : iD = json['ID'] as int?,
      title = json['title'] as String?,
      subtitle = json['subtitle'] as String?,
      amount = json['amount'] as int?,
      sign = (json['sign'] as String?)?.toPayoutItemSign(),
      type = (json['type'] as String? ?? "CALL").toTransactionType(),
      status = json['status'] as String?,
      createdAt = json['createdAt'] as String?,
      updatedAt = json['updatedAt'] as String?;

  Map<String, dynamic> toJson() => {
    'ID': iD,
    'title': title,
    'subtitle': subtitle,
    'amount': amount,
    'sign': sign?.name,
    'type': type?.name,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };
}
