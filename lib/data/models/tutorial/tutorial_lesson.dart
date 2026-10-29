class TutorialLesson {
  final int? id;
  final String? title;
  final String? lessonUrl;

  TutorialLesson({this.id, this.title, this.lessonUrl});

  TutorialLesson.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      title = json['title'] as String?,
      lessonUrl = json['lessonUrl'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'lessonUrl': lessonUrl,
  };
}
