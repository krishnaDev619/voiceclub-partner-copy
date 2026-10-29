import 'package:voiceclub_partner/data/models/account/reverse_call_user.dart';

class GetReverseCallsResponse {
  final List<ReverseCallUser>? users;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  GetReverseCallsResponse({
    this.users,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  GetReverseCallsResponse.fromJson(Map<String, dynamic> json)
    : users =
          (json['users'] as List?)
              ?.map(
                (dynamic e) =>
                    ReverseCallUser.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'users': users?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
