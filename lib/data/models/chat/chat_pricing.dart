import 'package:hive_ce_flutter/hive_flutter.dart';

part 'chat_pricing.g.dart';

@HiveType(typeId: 7)
class ChatPricing {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final int? price;
  @HiveField(2)
  final String? cta;

  ChatPricing({this.id, this.price, this.cta});

  ChatPricing.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      cta = json['cta'] as String?,
      price = json['price'] as int?;

  Map<String, dynamic> toJson() => {'id': id, 'cta': cta, 'price': price};
}
