import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/wallet/tax_items.dart';

class ResultWalletModel extends Equatable {
  final String? title;
  final String? subtitle;
  final num? paymentValue;
  final num? getAmount;
  final String? action;
  final int? status;
  final String? createdAt;
  final String? updatedAt;
  final List<TaxItems>? taxItems;
  final TransactionType? type;
  final int? iD;
  final HoldStatus? holdStatus;
  final int? paymentId;

  const ResultWalletModel({
    this.title,
    this.subtitle,
    this.paymentValue,
    this.getAmount,
    this.action,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.taxItems,
    this.type,
    this.iD,
    this.paymentId,
    this.holdStatus,
  });

  ResultWalletModel.fromJson(Map<String, dynamic> json)
    : title = json['title'] as String?,
      subtitle = json['subtitle'] as String?,
      paymentValue = json['payment_value'] as num?,
      getAmount = json['amount'] as num?,
      action = json['action'] as String?,
      status = json['status'] as int?,
      createdAt = json['createdAt'] as String?,
      updatedAt = json['updatedAt'] as String?,
      taxItems =
          (json['tax_items'] as List?)
              ?.map((dynamic e) => TaxItems.fromJson(e as Map<String, dynamic>))
              .toList(),
      iD = json['ID'] as int?,
      holdStatus = (json['hold_status'] as String? ?? "PAID").toHoldStatus(),
      paymentId = json['payment_id'] as int?,
      type = (json['type'] as String? ?? "CALL").toTransactionType();

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'payment_value': paymentValue,
    'amount': getAmount,
    'action': action,
    'status': status,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'tax_items': taxItems?.map((e) => e.toJson()).toList(),
    'type': type?.value,
    'hold_status': holdStatus?.value,
    'ID': iD,
    'payment_id': paymentId,
  };

  @override
  List<Object?> get props => [iD];
}
