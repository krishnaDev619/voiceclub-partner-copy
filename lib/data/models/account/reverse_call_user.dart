import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

class ReverseCallUser {
  final UserDataModel? user;
  final int? accountId;

  ReverseCallUser({this.user, this.accountId});

  ReverseCallUser.fromJson(Map<String, dynamic> json)
    : user =
          (json['user'] as Map<String, dynamic>?) != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      accountId = json['account_id'] as int?;

  Map<String, dynamic> toJson() => {
    'user': user?.toJson(),
    'account_id': accountId,
  };
}
