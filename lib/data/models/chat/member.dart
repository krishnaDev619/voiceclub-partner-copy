import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

part 'member.g.dart';

@HiveType(typeId: 5)
class ChatMember {
  @HiveField(0)
  final int? accountId;
  @HiveField(1)
  final UserDataModel? user;
  @HiveField(2)
  final String? accountType;
  @HiveField(3)
  final String? presence;

  ChatMember({this.accountId, this.user, this.accountType, this.presence});

  ChatMember.fromJson(Map<String, dynamic> json)
    : accountId = json['account_id'] as int?,
      user =
          (json['user'] as Map<String, dynamic>?) != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      presence = json['presence'] as String?,
      accountType = json['account_type'] as String?;

  Map<String, dynamic> toJson() => {
    'account_id': accountId,
    'user': user?.toJson(),
    'presence': presence,
    'account_type': accountType,
  };
}
