class Tutorial {
  final String? title;
  final String? subtitle;
  final int? duration;
  final String? url;

  Tutorial({this.title, this.subtitle, this.duration, this.url});

  Tutorial.fromJson(Map<String, dynamic> json)
    : title = json['title'] as String?,
      subtitle = json['subtitle'] as String?,
      duration = json['duration'] as int?,
      url = json['url'] as String?;

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'duration': duration,
    'url': url,
  };
}
