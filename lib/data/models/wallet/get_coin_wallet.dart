class GetCoinWalletResponse {
  final int? id;
  final num? amountRemaining;
  final String? createdAt;
  final String? updatedAt;

  GetCoinWalletResponse({
    this.id,
    this.amountRemaining,
    this.createdAt,
    this.updatedAt,
  });

  GetCoinWalletResponse.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      amountRemaining = json['amount_remaining'] as num?,
      createdAt = json['created_at'] as String?,
      updatedAt = json['updated_at'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount_remaining': amountRemaining,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
