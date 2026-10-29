class TaxItems {
  final String? name;
  final num? rate;

  TaxItems({this.name, this.rate});

  TaxItems.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String?,
      rate = json['rate'] as double?;

  Map<String, dynamic> toJson() => {'name': name, 'rate': rate};
}
