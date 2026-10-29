class LessonDto {
  final int? duration;
  final int? id;
  final String? subtitle;
  final String? thumbnail;
  final String? title;
  final String? url;

  LessonDto({
    this.duration,
    this.id,
    this.subtitle,
    this.thumbnail,
    this.title,
    this.url,
  });

  LessonDto.fromJson(Map<String, dynamic> json)
    : duration = json['duration'] as int?,
      id = json['id'] as int?,
      subtitle = json['subtitle'] as String?,
      thumbnail = json['thumbnail'] as String?,
      title = json['title'] as String?,
      url = json['url'] as String?;

  Map<String, dynamic> toJson() => {
    'duration': duration,
    'id': id,
    'subtitle': subtitle,
    'thumbnail': thumbnail,
    'title': title,
    'url': url,
  };
}
