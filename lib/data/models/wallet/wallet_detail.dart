class WalletDetail {
  final num? plusValue;
  final num? minusValue;
  final int? numberOfCalls;
  final int? partnerNumberOfCalls;
  final num? totalValue;
  final num? giftAmount;

  WalletDetail({
    this.plusValue,
    this.minusValue,
    this.numberOfCalls,
    this.partnerNumberOfCalls,
    this.totalValue,
    this.giftAmount,
  });

  WalletDetail.fromJson(Map<String, dynamic> json)
    : plusValue = json['plusValue'] as num?,
      minusValue = json['minusValue'] as num?,
      numberOfCalls = json['numberOfCalls'] as int?,
      partnerNumberOfCalls = json['girlNumberOfCalls'] as int?,
      totalValue = json['totalValue'] as num?,
      giftAmount = json['giftAmount'] as num?;

  Map<String, dynamic> toJson() => {
    'plusValue': plusValue,
    'minusValue': minusValue,
    'numberOfCalls': numberOfCalls,
    'girlNumberOfCalls': partnerNumberOfCalls,
    'totalValue': totalValue,
    'giftAmount': giftAmount,
  };
}
