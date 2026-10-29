import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

class ConversionUser extends Equatable {
  final UserDataModel? user;
  final int? accountId;
  final int? duration;
  final int? callCount;

  const ConversionUser({
    this.user,
    this.accountId,
    this.duration,
    this.callCount,
  });

  ConversionUser.fromJson(Map<String, dynamic> json)
    : user =
          (json['user'] as Map<String, dynamic>?) != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      accountId = json['account_id'] as int?,
      duration = json['duration'] as int?,
      callCount = json['call_count'] as int?;

  Map<String, dynamic> toJson() => {
    'user': user?.toJson(),
    'account_id': accountId,
    'duration': duration,
    'call_count': callCount,
  };

  @override
  List<Object?> get props => [accountId];
}
