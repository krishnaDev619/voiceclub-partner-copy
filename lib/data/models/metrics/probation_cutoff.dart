class ProbationCutoff {
  final num? appOnlineDuration;
  final num? avgCallDuration;
  final num? avgCallDurationNew;
  final num? avgCallDurationOld;
  final num? callToAudio;
  final num? totalCall;
  final num? totalChatReceived;
  final num? totalChatSent;

  ProbationCutoff({
    this.appOnlineDuration,
    this.avgCallDuration,
    this.avgCallDurationNew,
    this.avgCallDurationOld,
    this.callToAudio,
    this.totalCall,
    this.totalChatReceived,
    this.totalChatSent,
  });

  ProbationCutoff.fromJson(Map<String, dynamic> json)
    : appOnlineDuration = json['app_online_duration'] as num?,
      avgCallDuration = json['avg_call_duration'] as num?,
      avgCallDurationNew = json['avg_call_duration_new'] as num?,
      avgCallDurationOld = json['avg_call_duration_old'] as num?,
      callToAudio = json['call_to_audio'] as num?,
      totalCall = json['total_call'] as num?,
      totalChatReceived = json['total_chat'] as num?,
      totalChatSent = json['total_chat_sent'] as num?;

  Map<String, dynamic> toJson() => {
    'app_online_duration': appOnlineDuration,
    'avg_call_duration': avgCallDuration,
    'avg_call_duration_new': avgCallDurationNew,
    'avg_call_duration_old': avgCallDurationOld,
    'call_to_audio': callToAudio,
    'total_call': totalCall,
    'total_chat': totalChatReceived,
    'total_chat_sent': totalChatSent,
  };
}
