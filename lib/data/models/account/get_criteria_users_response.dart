import 'package:voiceclub_partner/data/models/account/conversion_user.dart';

class GetCriteriaUsersResponseModel {
  final List<ConversionUser>? users;
  final int? cutoff;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  GetCriteriaUsersResponseModel({
    this.users,
    this.cutoff,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  GetCriteriaUsersResponseModel.fromJson(Map<String, dynamic> json)
    : users =
          (json['users'] as List?)
              ?.map(
                (dynamic e) =>
                    ConversionUser.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      cutoff = json['cutoff'] as int?,
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'users': users?.map((e) => e.toJson()).toList(),
    'cutoff': cutoff,
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
