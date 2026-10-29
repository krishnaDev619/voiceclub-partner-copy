class ProbationStat {
  final String? date;
  final bool? meetingAttended;
  final num? totalCall;
  final num? avgCallDuration;
  final num? avgCallDurationNew;
  final num? avgCallDurationOld;
  final num? appOnlineDuration;
  final num? callToAudio;
  final num? totalChatReceived;
  final num? totalChatSent;

  ProbationStat({
    this.date,
    this.meetingAttended,
    this.totalCall,
    this.avgCallDuration,
    this.avgCallDurationNew,
    this.avgCallDurationOld,
    this.appOnlineDuration,
    this.callToAudio,
    this.totalChatReceived,
    this.totalChatSent,
  });

  ProbationStat.fromJson(Map<String, dynamic> json)
    : date = json['date'] as String?,
      meetingAttended = json['meeting_attended'] as bool?,
      totalCall = json['total_call'] as num?,
      avgCallDuration = json['avg_call_duration'] as num?,
      avgCallDurationNew = json['avg_call_duration_new'] as num?,
      avgCallDurationOld = json['avg_call_duration_old'] as num?,
      appOnlineDuration = json['app_online_duration'] as num?,
      callToAudio = json['call_to_audio'] as num?,
      totalChatReceived = json['total_chat'] as num?,
      totalChatSent = json['total_chat_sent'] as num?;

  Map<String, dynamic> toJson() => {
    'date': date,
    'meeting_attended': meetingAttended,
    'total_call': totalCall,
    'avg_call_duration': avgCallDuration,
    'avg_call_duration_new': avgCallDurationNew,
    'avg_call_duration_old': avgCallDurationOld,
    'app_online_duration': appOnlineDuration,
    'call_to_audio': callToAudio,
    'total_chat': totalChatReceived,
    'total_chat_sent': totalChatSent,
  };

  // Getter to convert the date string to DateTime
  DateTime? get dateAsDateTime {
    if (date == null) return null;
    // Assuming the date is in ISO 8601 format
    return DateTime.parse(date!);
    // If your date is in another format, you might need to parse it like this:
    // return DateFormat("your_date_format_here").parse(date!);
  }
}
