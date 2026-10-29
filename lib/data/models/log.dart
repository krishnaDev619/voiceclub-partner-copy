import 'package:equatable/equatable.dart';

class LogModel extends Equatable {
  final int? accountId;
  final String? lastCalledAt;
  final int? callCount;
  final String? name;
  final int? uid;
  final bool? isBlocked;

  const LogModel({
    this.accountId,
    this.lastCalledAt,
    this.callCount,
    this.name,
    this.uid,
    this.isBlocked,
  });

  int get logId {
    final combinedString = '$accountId$name$uid';
    return combinedString.hashCode;
  }

  LogModel.fromJson(Map<String, dynamic> json)
    : accountId = json['account_id'] as int?,
      lastCalledAt = json['last_called_at'] as String?,
      callCount = json['call_count'] as int?,
      name = json['name'] as String?,
      uid = json['uid'] as int?,
      isBlocked = json['is_blocked'] as bool?;

  Map<String, dynamic> toJson() => {
    'account_id': accountId,
    'last_called_at': lastCalledAt,
    'call_count': callCount,
    'name': name,
    'uid': uid,
    'is_blocked': isBlocked,
  };

  @override
  List<Object?> get props => [uid];
}
