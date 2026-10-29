class GetCallDetailsResponseModel {
  final int? callCount;
  final int? timeToConvert;
  final int? totalCallDuration;

  GetCallDetailsResponseModel({
    this.callCount,
    this.timeToConvert,
    this.totalCallDuration,
  });

  GetCallDetailsResponseModel.fromJson(Map<String, dynamic> json)
    : callCount = json['call_count'] as int?,
      timeToConvert = json['time_to_convert'] as int?,
      totalCallDuration = json['total_call_duration'] as int?;

  Map<String, dynamic> toJson() => {
    'call_count': callCount,
    'time_to_convert': timeToConvert,
    'total_call_duration': totalCallDuration,
  };
}
