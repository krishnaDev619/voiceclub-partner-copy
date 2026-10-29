class Tax {
  final String? type;
  final num? percentage;
  final num? amount;

  Tax({this.type, this.percentage, this.amount});

  Tax.fromJson(Map<String, dynamic> json)
    : type = json['type'] as String?,
      percentage = json['percentage'] as num?,
      amount = json['amount'] as num?;

  Map<String, dynamic> toJson() => {
    'type': type,
    'percentage': percentage,
    'amount': amount,
  };
}
