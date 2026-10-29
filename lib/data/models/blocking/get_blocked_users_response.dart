import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

class GetBlockedUsersResponseModel {
  final List<BlockedUsers>? blockedUsers;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  GetBlockedUsersResponseModel({
    this.blockedUsers,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  GetBlockedUsersResponseModel.fromJson(Map<String, dynamic> json)
    : blockedUsers =
          (json['blocked_users'] as List?)
              ?.map(
                (dynamic e) => BlockedUsers.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'blocked_users': blockedUsers?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}

class BlockedUsers extends Equatable {
  final UserDataModel? blockedUser;
  final int? blockingAccountId;
  final int? blockedAccountId;
  final String? reason;

  const BlockedUsers({
    this.blockedUser,
    this.blockingAccountId,
    this.blockedAccountId,
    this.reason,
  });

  BlockedUsers.fromJson(Map<String, dynamic> json)
    : blockedUser =
          (json['blocked_user'] as Map<String, dynamic>?) != null
              ? UserDataModel.fromJson(
                json['blocked_user'] as Map<String, dynamic>,
              )
              : null,
      blockingAccountId = json['blocking_account_id'] as int?,
      blockedAccountId = json['blocked_account_id'] as int?,
      reason = json['reason'] as String?;

  Map<String, dynamic> toJson() => {
    'blocked_user': blockedUser?.toJson(),
    'blocking_account_id': blockingAccountId,
    'blocked_account_id': blockedAccountId,
    'reason': reason,
  };

  @override
  List<Object?> get props => [blockedAccountId];
}
