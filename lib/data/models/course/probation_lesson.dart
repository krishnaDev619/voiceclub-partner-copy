import 'package:voiceclub_partner/data/models/course/remote/lesson_dto.dart';

class ProbationLesson {
  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnail;
  final int totalDurationInSeconds;
  int watchedDurationInSeconds;
  bool isCompleted;
  bool isLocked;

  ProbationLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.watchedDurationInSeconds,
    required this.isCompleted,
    required this.isLocked,
    required this.thumbnail,
    required this.videoUrl,
    required this.totalDurationInSeconds,
  });

  String _formatTime({required int seconds, required bool isCompleted}) {
    final minutes = ((seconds % 3600) ~/ 60);
    final remainingSeconds = seconds % 60;

    final formattedMinutes = minutes.toString().padLeft(2, '0');
    final formattedSeconds = remainingSeconds.toString().padLeft(2, '0');
    if (isCompleted) {
      return "${minutes > 0 ? formattedMinutes : '1'} min";
    } else {
      return "${minutes > 0 ? '${formattedMinutes}m ' : ''}${formattedSeconds}s left";
    }
  }

  String get getFormattedDuration {
    if (isCompleted) {
      return _formatTime(seconds: totalDurationInSeconds, isCompleted: true);
    } else {
      if (watchedDurationInSeconds <= 0 ||
          watchedDurationInSeconds >= totalDurationInSeconds) {
        return _formatTime(seconds: totalDurationInSeconds, isCompleted: true);
      } else {
        return _formatTime(
          seconds: totalDurationInSeconds - watchedDurationInSeconds,
          isCompleted: false,
        );
      }
    }
  }

  void markAsCompleted() {
    updateWatchedDuration(totalDurationInSeconds);
    isCompleted = true;
  }

  void unlockLesson() {
    isLocked = false;
  }

  void updateWatchedDuration(int newDuration) {
    if (newDuration > watchedDurationInSeconds) {
      if (newDuration >= totalDurationInSeconds) {
        watchedDurationInSeconds = totalDurationInSeconds;
      } else {
        watchedDurationInSeconds = newDuration;
      }
    }
  }

  Duration get startDuration {
    if (isCompleted) {
      return Duration.zero;
    } else {
      if (watchedDurationInSeconds <= 0 ||
          watchedDurationInSeconds >= totalDurationInSeconds) {
        return Duration.zero;
      } else {
        return Duration(seconds: watchedDurationInSeconds);
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': description,
      'watchedDurationInSeconds': watchedDurationInSeconds,
      'isCompleted': isCompleted,
      'isLocked': isLocked,
      'url': videoUrl,
      'thumbnail': thumbnail,
      'duration': totalDurationInSeconds,
    };
  }

  static ProbationLesson fromJson(Map<String, dynamic> json) {
    return ProbationLesson(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['subtitle'] as String,
      watchedDurationInSeconds: json['watchedDurationInSeconds'] as int,
      totalDurationInSeconds: json['duration'] as int,
      isCompleted: json['isCompleted'] as bool,
      isLocked: json['isLocked'] as bool,
      videoUrl: json['url'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }

  static ProbationLesson fromDTO({
    required LessonDto lessonDto,
    required ProbationLesson? existingLesson,
    required bool? isCompleted,
  }) {
    bool completed =
        isCompleted == true ? true : existingLesson?.isCompleted ?? false;
    return ProbationLesson(
      id: lessonDto.id ?? 0,
      title: lessonDto.title ?? "",
      description: lessonDto.subtitle ?? "",
      totalDurationInSeconds: lessonDto.duration ?? 0,
      videoUrl: lessonDto.url ?? "",
      thumbnail: lessonDto.thumbnail ?? "",
      isCompleted: completed,
      isLocked:
          completed
              ? false
              : existingLesson?.isLocked ?? (lessonDto.id == 1 ? false : true),
      watchedDurationInSeconds: existingLesson?.watchedDurationInSeconds ?? 0,
    );
  }
}
