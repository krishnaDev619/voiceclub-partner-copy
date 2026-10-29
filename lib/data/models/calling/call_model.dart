import 'package:voiceclub_partner/core/constants/enums.dart';

class CallModel {
  final String? token;
  final bool? callAccepted;
  final int? callerUid;
  final int? callOnlySeconds;
  final int? uid;
  final String? channelName;
  final String? partnerNumber;
  final String? partnerName;
  final String? avatar;
  final String? name;
  final num? currentBalance;
  final int? durationSeconds;
  final int? dateTime;
  final bool? callEnd;
  final String? callAcceptedTime;
  final int? callerAccountId;
  final int? accountId;
  final String? state;
  final String? label;
  final String? callStatLabel;
  final RingState? ringState;
  final List<String>? questions;
  final num? spend;
  final num? limit;
  final num? limitFriend;
  final num? limitBestFriend;
  final num? limitGoodFriend;
  final num? totalDurationSeconds;
  final num? perSecondCost;
  final bool? showBehaviourProgress;
  final String? demandLanguage;
  final String? supplyLanguage;
  final int? rejectedCallCount;
  String? customName;
  final num? lifeTimeCallCount;
  final num? lifeTimeCallDuration;
  final String? gameUrl;

  CallModel({
    this.token,
    this.callAccepted,
    this.callerUid,
    this.callOnlySeconds,
    this.uid,
    this.channelName,
    this.partnerNumber,
    this.partnerName,
    this.name,
    this.avatar,
    this.currentBalance,
    this.durationSeconds,
    this.dateTime,
    this.callEnd,
    this.callAcceptedTime,
    this.callerAccountId,
    this.accountId,
    this.state,
    this.label,
    this.callStatLabel,
    this.ringState,
    this.questions,
    this.spend,
    this.limit,
    this.limitFriend,
    this.limitGoodFriend,
    this.limitBestFriend,
    this.totalDurationSeconds,
    this.perSecondCost,
    this.showBehaviourProgress,
    this.demandLanguage,
    this.supplyLanguage,
    this.rejectedCallCount,
    this.customName,
    this.lifeTimeCallCount,
    this.lifeTimeCallDuration,
    this.gameUrl,
  });

  CallModel.fromJson(Map<String, dynamic> json)
    : token = json['token'] as String?,
      callAccepted = json['call_accepted'] as bool?,
      callerUid = json['caller_uid'] as int?,
      callOnlySeconds = json['call_only_seconds'] as int?,
      uid = json['uid'] as int?,
      channelName = json['channel_name'] as String?,
      partnerNumber = json['girlNumber'] as String?,
      partnerName = json['girlName'] as String?,
      name = json['name'] as String?,
      avatar = json['avatar'] as String?,
      currentBalance = json['current_balance'] as num?,
      durationSeconds = json['duration_seconds'] as int?,
      dateTime = json['date_time'] as int?,
      callEnd = json['call_end'] as bool?,
      callAcceptedTime = json['call_accepted_time'] as String?,
      callerAccountId = json['caller_account_id'] as int?,
      accountId = json['account_id'] as int?,
      state = json['state'] as String?,
      label = json['label'] as String?,
      callStatLabel = json['call_stat_label'] as String?,
      spend = json['spend'] as num?,
      limit = json['limit'] as num?,
      limitFriend = json['limit_friend'] as num?,
      limitGoodFriend = json['limit_good_friend'] as num?,
      limitBestFriend = json['limit_best_friend'] as num?,
      totalDurationSeconds = json['total_duration_seconds'] as num?,
      perSecondCost = json['per_second_cost'] as num?,
      showBehaviourProgress = json['show_behaviour_progress'] as bool?,
      questions =
          (json['questions'] as List?)
              ?.map((dynamic e) => e as String)
              .toList(),
      ringState = (json['ring_state'] as String? ?? 'CALLING').toRingState(),
      demandLanguage = json['demand_language'] as String?,
      supplyLanguage = json['supply_language'] as String?,
      rejectedCallCount = json['rejected_call_count'] as int?,
      customName = json['custom_name'] as String?,
      lifeTimeCallCount = json['lifetime_call_count'] as num?,
      lifeTimeCallDuration = json['lifetime_call_duration'] as num?,
      gameUrl = json['game_url'] as String?;

  Map<String, dynamic> toJson() => {
    'token': token,
    'call_accepted': callAccepted,
    'caller_uid': callerUid,
    'call_only_seconds': callOnlySeconds,
    'uid': uid,
    'channel_name': channelName,
    'girlNumber': partnerNumber,
    'girlName': partnerName,
    'name': name,
    'avatar': avatar,
    'current_balance': currentBalance,
    'duration_seconds': durationSeconds,
    'date_time': dateTime,
    'call_end': callEnd,
    'call_accepted_time': callAcceptedTime,
    'caller_account_id': callerAccountId,
    'account_id': accountId,
    'state': state,
    'label': label,
    'call_stat_label': callStatLabel,
    'spend': spend,
    'limit': limit,
    'limit_friend': limitFriend,
    'limit_good_friend': limitGoodFriend,
    'limit_best_friend': limitBestFriend,
    'total_duration_seconds': totalDurationSeconds,
    'per_second_cost': perSecondCost,
    'show_behaviour_progress': showBehaviourProgress,
    'questions': questions,
    'ring_state': ringState?.name ?? 'CALLING',
    'demand_language': demandLanguage,
    'supply_language': supplyLanguage,
    'rejected_call_count': rejectedCallCount,
    'custom_name': customName,
    'lifetime_call_count': lifeTimeCallCount,
    'lifetime_call_duration': lifeTimeCallDuration,
    'game_url': gameUrl,
  };
}
