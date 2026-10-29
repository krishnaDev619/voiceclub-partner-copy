import 'package:get/get.dart';
import 'package:voiceclub_partner/data/models/course/probation_lesson.dart';
import 'package:voiceclub_partner/data/models/course/remote/chapter_dto.dart';

class ProbationChapter {
  final int id;
  final String title;
  final List<ProbationLesson> lessons;
  bool isCompleted;

  ProbationChapter({
    required this.id,
    required this.title,
    required this.lessons,
    required this.isCompleted,
  });

  void markAsCompleted() {
    isCompleted = true;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      'isCompleted': isCompleted,
    };
  }

  static ProbationChapter fromJson(Map<String, dynamic> json) {
    return ProbationChapter(
      id: json['id'] as int,
      title: json['title'] as String,
      lessons:
          (json['lessons'] as List?)
              ?.map(
                (dynamic e) =>
                    ProbationLesson.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      isCompleted: json['isCompleted'] as bool,
    );
  }

  static ProbationChapter fromDTO({
    required ChapterDto chapterDto,
    required ProbationChapter? existingChapter,
  }) {
    return ProbationChapter(
      id: chapterDto.id ?? 0,
      title: chapterDto.name ?? "",
      lessons:
          chapterDto.courses?.map((e) {
            ProbationLesson? existingLesson;
            if (existingChapter != null) {
              existingLesson = existingChapter.lessons.firstWhereOrNull(
                (element) => element.id == e.id,
              );
            }
            return ProbationLesson.fromDTO(
              lessonDto: e,
              existingLesson: existingLesson,
              isCompleted: chapterDto.isCompleted,
            );
          }).toList() ??
          [],
      isCompleted: existingChapter?.isCompleted ?? false,
    );
  }
}
