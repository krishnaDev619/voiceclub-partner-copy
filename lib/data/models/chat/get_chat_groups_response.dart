import 'package:voiceclub_partner/data/models/chat/chat_group.dart';

class GetChatGroupsResponseModel {
  final String? message;
  final List<ChatGroup>? groups;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  GetChatGroupsResponseModel({
    this.message,
    this.groups,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  GetChatGroupsResponseModel.fromJson(Map<String, dynamic> json)
    : message = json['message'] as String?,
      groups =
          (json['groups'] as List?)
              ?.map(
                (dynamic e) => ChatGroup.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'message': message,
    'groups': groups?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
