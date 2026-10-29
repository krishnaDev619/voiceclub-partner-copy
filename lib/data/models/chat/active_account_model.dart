import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

class ActiveAccount extends Equatable {
  final int? accountId;
  final String? lastSeenAt;
  final UserDataModel? user;

  const ActiveAccount({this.accountId, this.lastSeenAt, this.user});

  ActiveAccount.fromJson(Map<String, dynamic> json)
    : accountId = json['id'] as int?,
      lastSeenAt = json['last_seen_at'] as String?,
      user =
          (json['user'] as Map<String, dynamic>?) != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null;

  Map<String, dynamic> toJson() => {
    'id': accountId,
    'last_seen_at': lastSeenAt,
    'user': user?.toJson(),
  };

  @override
  List<Object?> get props => [accountId];
}
