import 'package:voiceclub_partner/data/models/chat/active_account_model.dart';

class ActiveUsersResponseModel {
  final List<ActiveAccount>? accounts;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  ActiveUsersResponseModel({
    this.accounts,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  ActiveUsersResponseModel.fromJson(Map<String, dynamic> json)
    : accounts =
          (json['accounts'] as List?)
              ?.map(
                (dynamic e) =>
                    ActiveAccount.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'accounts': accounts?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
