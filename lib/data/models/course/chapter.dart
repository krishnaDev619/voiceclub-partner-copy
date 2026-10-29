import 'package:get/get.dart';
import 'package:voiceclub_partner/data/models/course/lesson.dart';
import 'package:voiceclub_partner/data/models/course/remote/chapter_dto.dart';

class Chapter {
  final int id;
  final String title;
  final List<Lesson> lessons;

  Chapter({required this.id, required this.title, required this.lessons});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }

  static Chapter fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as int,
      title: json['title'] as String,
      lessons:
          (json['lessons'] as List?)
              ?.map((dynamic e) => Lesson.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static Chapter fromDTO({
    required ChapterDto chapterDto,
    required Chapter? existingChapter,
  }) {
    return Chapter(
      id: chapterDto.id ?? 0,
      title: chapterDto.name ?? "",
      lessons:
          chapterDto.courses?.map((e) {
            Lesson? existingLesson;
            if (existingChapter != null) {
              existingLesson = existingChapter.lessons.firstWhereOrNull(
                (element) => element.id == e.id,
              );
            }
            return Lesson.fromDTO(
              lessonDto: e,
              existingLesson: existingLesson,
              title: chapterDto.name ?? "",
              chapterId: chapterDto.id ?? 0,
            );
          }).toList() ??
          [],
    );
  }
}
