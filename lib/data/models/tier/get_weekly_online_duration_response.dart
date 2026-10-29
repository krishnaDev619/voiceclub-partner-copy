import 'package:voiceclub_partner/core/constants/enums.dart';

class GetWeeklyOnlineDurationResponseModel {
  final Map<DayOfWeek, num>? onlineDuration;
  final num? penaltyAmount;
  final num? rewardAmount;
  final num? maxDuration;
  final num? high;
  final num? low;

  GetWeeklyOnlineDurationResponseModel({
    this.onlineDuration,
    this.penaltyAmount,
    this.rewardAmount,
    this.maxDuration,
    this.high,
    this.low,
  });

  GetWeeklyOnlineDurationResponseModel.fromJson(Map<String, dynamic> json)
    : onlineDuration = (json['durations'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key.toDayOfWeek(), value as num),
      ),
      penaltyAmount = json['penalty_amount'] as num?,
      rewardAmount = json['reward_amount'] as num?,
      maxDuration = json['max_duration'] as num?,
      high = json['high'] as num?,
      low = json['low'] as num?;

  Map<String, dynamic> toJson() => {
    'durations': onlineDuration?.map(
      (key, value) => MapEntry(key.name.toLowerCase(), value),
    ),
    'penalty_amount': penaltyAmount,
    'reward_amount': rewardAmount,
    'max_duration': maxDuration,
    'high': high,
    'low': low,
  };

  int get getThisWeekOnlineDuration {
    try {
      final today = DateTime.now().weekday.toDayOfWeek();
      final daysPassed = DayOfWeek.values.sublist(
        0,
        DayOfWeek.values.indexOf(today),
      );
      final totalDuration = daysPassed.fold<num>(0, (sum, day) {
        return (sum + (onlineDuration?[day] ?? 0));
      });
      return (totalDuration * 3600).floor();
    } catch (_) {
      return 0;
    }
  }

  String get getThisWeekOnlineAverage {
    try {
      final today = DateTime.now().weekday.toDayOfWeek();
      final daysPassed = DayOfWeek.values.sublist(
        0,
        DayOfWeek.values.indexOf(today),
      );
      final totalDuration = daysPassed.fold<num>(0, (sum, day) {
        return (sum + (onlineDuration?[day] ?? 0));
      });
      if (daysPassed.isNotEmpty) {
        return ((totalDuration).floor() / daysPassed.length).toStringAsFixed(1);
      } else {
        return "0.0";
      }
    } catch (_) {
      return "0.0";
    }
  }

  int get getThisWeeksDaysPassed {
    try {
      final today = DateTime.now().weekday.toDayOfWeek();
      final daysPassed = DayOfWeek.values.sublist(
        0,
        DayOfWeek.values.indexOf(today),
      );
      return daysPassed.length;
    } catch (_) {
      return 0;
    }
  }

  // Last 7 days, sum of all values in map
  int get getTotalOnlineDuration {
    try {
      final totalDuration = DayOfWeek.values.fold<num>(0, (sum, day) {
        return (sum + (onlineDuration?[day] ?? 0));
      });
      return (totalDuration * 3600).floor();
    } catch (_) {
      return 0;
    }
  }
}
