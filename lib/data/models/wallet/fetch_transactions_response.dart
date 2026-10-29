import 'package:voiceclub_partner/data/models/wallet/result_wallet.dart';

class FetchTransactionsResponseModel {
  final String? message;
  final List<ResultWalletModel>? resultWalletList;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  FetchTransactionsResponseModel({
    this.message,
    this.resultWalletList,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  FetchTransactionsResponseModel.fromJson(Map<String, dynamic> json)
    : message = json['message'] as String?,
      resultWalletList =
          (json['result_wallet'] as List?)
              ?.map(
                (dynamic e) =>
                    ResultWalletModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'message': message,
    'result_wallet': resultWalletList?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
