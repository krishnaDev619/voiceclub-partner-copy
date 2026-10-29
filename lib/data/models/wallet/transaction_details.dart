import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/data/models/wallet/slab.dart';
import 'package:voiceclub_partner/data/models/wallet/tax_items.dart';

class TransactionDetailsModel {
  final int? iD;
  final String? title;
  final String? subtitle;
  final String? channelId;
  final num? amount;
  final num? totalAmount;
  final num? paidAmount;
  final num? netAmount;
  final String? action;
  final String? reason;
  final TransactionType? type;
  final num? status;
  final num? callDuration;
  final String? callStartTime;
  final String? callEndTime;
  final String? price;
  final num? callRevenueRatio;
  final UserDataModel? user;
  final List<TaxItems>? taxItems;
  final String? createdAt;
  final String? updatedAt;
  final HoldStatus? holdStatus;
  final List<Slab>? slabs;
  final bool? isPercentage;

  TransactionDetailsModel({
    this.iD,
    this.title,
    this.subtitle,
    this.channelId,
    this.amount,
    this.paidAmount,
    this.netAmount,
    this.action,
    this.type,
    this.status,
    this.callDuration,
    this.callStartTime,
    this.callEndTime,
    this.callRevenueRatio,
    this.user,
    this.taxItems,
    this.createdAt,
    this.updatedAt,
    this.totalAmount,
    this.holdStatus,
    this.reason,
    this.price,
    this.slabs,
    this.isPercentage,
  });

  TransactionDetailsModel.fromJson(Map<String, dynamic> json)
    : iD = json['id'] as int?,
      title = json['title'] as String?,
      subtitle = json['subtitle'] as String?,
      amount = json['amount'] as num?,
      totalAmount = json['total_amount'] as num?,
      paidAmount = json['paid_amount'] as num?,
      netAmount = json['net_amount'] as num?,
      action = json['action'] as String?,
      type = (json['type'] as String? ?? "CALL").toTransactionType(),
      status = json['status'] as num?,
      price = (json['price'] as String?),
      callDuration = json['call_duration'] as num?,
      callStartTime = json['call_start_time'] as String?,
      callEndTime = json['call_end_time'] as String?,
      callRevenueRatio = json['call_revenue_ratio'] as num?,
      user =
          (json['user'] as Map<String, dynamic>?) != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      taxItems =
          (json['tax_items'] as List?)
              ?.map((dynamic e) => TaxItems.fromJson(e as Map<String, dynamic>))
              .toList(),
      createdAt = json['created_at'] as String?,
      holdStatus = (json['hold_status'] as String? ?? "PAID").toHoldStatus(),
      slabs =
          (json['slabs'] as List?)
              ?.map((dynamic e) => Slab.fromJson(e as Map<String, dynamic>))
              .toList(),
      channelId = json['channel_id'] as String?,
      reason = json['reason'] as String?,
      updatedAt = json['updated_at'] as String?,
      isPercentage = json['is_percentage'] as bool?;

  Map<String, dynamic> toJson() => {
    'id': iD,
    'title': title,
    'subtitle': subtitle,
    'amount': amount,
    'paid_amount': paidAmount,
    'net_amount': netAmount,
    'total_amount': totalAmount,
    'action': action,
    'type': type?.value,
    'status': status,
    'call_duration': callDuration,
    'call_start_time': callStartTime,
    'call_end_time': callEndTime,
    'call_revenue_ratio': callRevenueRatio,
    'user': user?.toJson(),
    'tax_items': taxItems?.map((e) => e.toJson()).toList(),
    'hold_status': holdStatus?.value,
    'created_at': createdAt,
    'channel_id': channelId,
    'reason': reason,
    'price': price,
    'updated_at': updatedAt,
    'slabs': slabs?.map((e) => e.toJson()).toList(),
    'is_percentage': isPercentage,
  };
}
