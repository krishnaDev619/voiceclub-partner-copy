class ChatFeaturesUnlockCriteriaResponseModel {
  final List<UnlockTimes>? unlockTimes;
  final int? successfulCallCounts;

  ChatFeaturesUnlockCriteriaResponseModel({
    this.unlockTimes,
    this.successfulCallCounts,
  });

  ChatFeaturesUnlockCriteriaResponseModel.fromJson(Map<String, dynamic> json)
    : unlockTimes =
          (json['unlock_times'] as List?)
              ?.map(
                (dynamic e) => UnlockTimes.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      successfulCallCounts = json['successful_call_counts'] as int?;

  Map<String, dynamic> toJson() => {
    'unlock_times': unlockTimes?.map((e) => e.toJson()).toList(),
    'successful_call_counts': successfulCallCounts,
  };
}

class UnlockTimes {
  final String? category;
  final num? timeInSeconds;

  UnlockTimes({this.category, this.timeInSeconds});

  UnlockTimes.fromJson(Map<String, dynamic> json)
    : category = json['category'] as String?,
      timeInSeconds = json['time_in_seconds'] as num?;

  Map<String, dynamic> toJson() => {
    'category': category,
    'time_in_seconds': timeInSeconds,
  };
}
