import 'package:intl/intl.dart';

class Meeting {
  final int? id;
  final String? title;
  final String? description;
  final String? startTime;
  final String? endTime;
  final String? googleMeetLink;

  Meeting({
    this.id,
    this.title,
    this.description,
    this.startTime,
    this.endTime,
    this.googleMeetLink,
  });

  Meeting.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      title = json['title'] as String?,
      description = json['description'] as String?,
      startTime = json['start_time'] as String?,
      endTime = json['end_time'] as String?,
      googleMeetLink = json['google_meet_link'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'start_time': startTime,
    'end_time': endTime,
    'google_meet_link': googleMeetLink,
  };

  DateTime get startDateTime => _parseLocalDateTime(startTime);

  DateTime get endDateTime => _parseLocalDateTime(endTime);

  DateTime _parseLocalDateTime(String? value) {
    try {
      if (value?.isNotEmpty != true) {
        return DateTime.now();
      }

      final sanitized =
          value!.endsWith('Z') ? value.substring(0, value.length - 1) : value;

      return DateTime.tryParse(sanitized) ?? DateTime.now();
    } catch (_) {
      return DateTime.now();
    }
  }

  bool get isMeetingOngoing {
    final now = DateTime.now();
    return now.isAfter(startDateTime.toUtc()) &&
        now.isBefore(endDateTime.toUtc());
  }

  bool get isMeetingEnded {
    return endDateTime.isBefore(DateTime.now());
  }

  String get formattedTimingString {
    final DateFormat formatter = DateFormat('h:mm a');

    String startTimeFormatted = formatter.format(startDateTime);
    String endTimeFormatted = formatter.format(endDateTime);

    if (startDateTime.minute == 0) {
      startTimeFormatted = DateFormat('h a').format(startDateTime);
    }
    if (endDateTime.minute == 0) {
      endTimeFormatted = DateFormat('h a').format(endDateTime);
    }

    return '$startTimeFormatted - $endTimeFormatted';
  }

  String get getDateString {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Convert startDateTime from UTC to IST (+5:30)
    final istStartDateTime = startDateTime.toLocal();
    final meetingDate = DateTime(
      istStartDateTime.year,
      istStartDateTime.month,
      istStartDateTime.day,
    );

    if (meetingDate == today) {
      return "Today";
    } else if (meetingDate == today.add(const Duration(days: 1))) {
      return "Tomorrow";
    } else {
      return DateFormat('dd MMM yyyy').format(startDateTime);
    }
  }
}
