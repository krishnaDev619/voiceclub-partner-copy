import 'package:equatable/equatable.dart';

class CallLog extends Equatable {
  final int? id;
  final String? token;
  final bool? callAccepted;
  final int? callAcceptedTime;
  final int? girlUid;
  final int? demandUid;
  final String? recordingUrl;
  final int? supplyAccountId;
  final int? demandAccountId;
  final bool? callRejected;
  final bool? countdownStarted;
  final String? channelName;
  final String? name;
  final String? supplyName;
  final int? callingSecond;
  final String? callState;
  final String? message;
  final String? reason;
  final int? callEndTime;
  final int? dateTime;
  final bool? callEnd;
  final String? createdAt;
  final String? updatedAt;

  const CallLog({
    this.id,
    this.token,
    this.callAccepted,
    this.callAcceptedTime,
    this.girlUid,
    this.demandUid,
    this.recordingUrl,
    this.supplyAccountId,
    this.demandAccountId,
    this.callRejected,
    this.countdownStarted,
    this.channelName,
    this.name,
    this.supplyName,
    this.callingSecond,
    this.callState,
    this.message,
    this.callEndTime,
    this.dateTime,
    this.callEnd,
    this.createdAt,
    this.updatedAt,
    this.reason,
  });

  CallLog.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      token = json['token'] as String?,
      callAccepted = json['call_accepted'] as bool?,
      callAcceptedTime = json['call_accepted_time'] as int?,
      girlUid = json['girl_uid'] as int?,
      demandUid = json['demand_uid'] as int?,
      recordingUrl = json['call_recording'] as String?,
      supplyAccountId = json['supply_account_id'] as int?,
      demandAccountId = json['demand_account_id'] as int?,
      callRejected = json['call_rejected'] as bool?,
      countdownStarted = json['countdown_started'] as bool?,
      channelName = json['channel_name'] as String?,
      name = json['name'] as String?,
      supplyName = json['supply_name'] as String?,
      callingSecond = json['calling_second'] as int?,
      callState = json['call_state'] as String?,
      message = json['message'] as String?,
      callEndTime = json['call_end_time'] as int?,
      dateTime = json['date_time'] as int?,
      callEnd = json['call_end'] as bool?,
      reason = json['reason'] as String?,
      createdAt = json['createdAt'] as String?,
      updatedAt = json['updatedAt'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'token': token,
    'call_accepted': callAccepted,
    'call_accepted_time': callAcceptedTime,
    'girl_uid': girlUid,
    'demand_uid': demandUid,
    'recordingUrl': recordingUrl,
    'supply_account_id': supplyAccountId,
    'demand_account_id': demandAccountId,
    'call_rejected': callRejected,
    'countdown_started': countdownStarted,
    'channel_name': channelName,
    'name': name,
    'supply_name': supplyName,
    'calling_second': callingSecond,
    'call_state': callState,
    'message': message,
    'call_end_time': callEndTime,
    'date_time': dateTime,
    'call_end': callEnd,
    'createdAt': createdAt,
    'reason': reason,
    'updatedAt': updatedAt,
  };

  @override
  List<Object?> get props => [id];
}
