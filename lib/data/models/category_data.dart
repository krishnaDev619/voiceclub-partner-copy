import 'package:voiceclub_partner/core/constants/enums.dart';

class CategoryDataModel {
  final int? id;
  final int? tierId;
  final String? name;
  final CategoryCode? categoryCode;
  final num? price;
  final int? priceId;

  CategoryDataModel({
    this.id,
    this.tierId,
    this.name,
    this.categoryCode,
    this.price,
    this.priceId,
  });

  CategoryDataModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      tierId = json['tier_id'] as int?,
      name = json['name'] as String?,
      categoryCode = (json['category_code'] as String? ?? '').toCategoryCode(),
      price = json['price'] as num?,
      priceId = json['price_id'] as int?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'tier_id': tierId,
    'name': name,
    'category_code': categoryCode?.name,
    'price': price,
    'price_id': priceId,
  };
}
