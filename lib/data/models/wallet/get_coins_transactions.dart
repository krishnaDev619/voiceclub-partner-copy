import 'package:voiceclub_partner/data/models/wallet/coins_result_wallet.dart';

class GetCoinsTransactions {
  final String? message;
  final List<CoinsResultWallet>? resultWallet;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  GetCoinsTransactions({
    this.message,
    this.resultWallet,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  GetCoinsTransactions.fromJson(Map<String, dynamic> json)
    : message = json['message'] as String?,
      resultWallet =
          (json['result_wallet'] as List?)
              ?.map(
                (dynamic e) =>
                    CoinsResultWallet.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'message': message,
    'result_wallet': resultWallet?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
