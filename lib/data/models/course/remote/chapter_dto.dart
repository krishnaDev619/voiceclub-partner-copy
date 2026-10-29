import 'package:voiceclub_partner/data/models/course/remote/lesson_dto.dart';

class ChapterDto {
  final List<LessonDto>? courses;
  final int? id;
  final String? name;
  final bool? isCompleted;

  ChapterDto({this.courses, this.id, this.name, this.isCompleted});

  ChapterDto.fromJson(Map<String, dynamic> json)
    : courses =
          (json['courses'] as List?)
              ?.map(
                (dynamic e) => LessonDto.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      id = json['id'] as int?,
      name = json['name'] as String?,
      isCompleted = json['isCompleted'] as bool?;

  Map<String, dynamic> toJson() => {
    'courses': courses?.map((e) => e.toJson()).toList(),
    'id': id,
    'name': name,
    'isCompleted': isCompleted,
  };
}
