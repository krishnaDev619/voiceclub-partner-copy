import 'package:voiceclub_partner/data/models/course/remote/lesson_dto.dart';

class Lesson {
  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnail;
  final int totalDurationInSeconds;
  final String chapterTitle;
  final int chapterId;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.videoUrl,
    required this.totalDurationInSeconds,
    required this.chapterTitle,
    required this.chapterId,
  });

  String get getFormattedDuration {
    final minutes = ((totalDurationInSeconds % 3600) ~/ 60);

    final formattedMinutes = minutes.toString().padLeft(2, '0');
    return "${minutes > 0 ? formattedMinutes : '1'} min";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'thumbnail': thumbnail,
      'totalDurationInSeconds': totalDurationInSeconds,
      'chapterTitle': chapterTitle,
    };
  }

  static Lesson fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      totalDurationInSeconds: json['totalDurationInSeconds'] as int,
      videoUrl: json['videoUrl'] as String,
      thumbnail: json['thumbnail'] as String,
      chapterTitle: json['chapterTitle'] as String,
      chapterId: json['chapterId'] as int,
    );
  }

  static Lesson fromDTO({
    required LessonDto lessonDto,
    required Lesson? existingLesson,
    required String title,
    required int chapterId,
  }) {
    return Lesson(
      id: lessonDto.id ?? 0,
      title: lessonDto.title ?? "",
      description: lessonDto.subtitle ?? "",
      totalDurationInSeconds: lessonDto.duration ?? 0,
      videoUrl: lessonDto.url ?? "",
      thumbnail: lessonDto.thumbnail ?? "",
      chapterTitle: title,
      chapterId: chapterId,
    );
  }
}
