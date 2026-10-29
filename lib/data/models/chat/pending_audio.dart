import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

class PendingAudio extends Equatable {
  final int? id;
  final int? accountId;
  final num? amount;
  final int? timeLeftInSecs;
  final UserDataModel? user;

  const PendingAudio({
    this.id,
    this.accountId,
    this.timeLeftInSecs,
    this.amount,
    this.user,
  });

  PendingAudio.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      accountId = json['account_id'] as int?,
      amount = json['amount'] as num?,
      timeLeftInSecs = json['time_left_in_secs'] as int?,
      user =
          (json['user'] as Map<String, dynamic>?) != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'account_id': accountId,
    'time_left_in_secs': timeLeftInSecs,
    'amount': amount,
    'user': user?.toJson(),
  };

  @override
  List<Object?> get props => [id];
}
