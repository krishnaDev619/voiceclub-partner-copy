class TutorModel {
  final int? id;
  final String? name;
  final String? title;
  final String? language;
  final String? imageUrl;
  final String? audioUrl;
  final String? voice;
  final String? videoUrl;
  final String? thumbnailUrl;

  TutorModel({
    this.id,
    this.name,
    this.title,
    this.language,
    this.imageUrl,
    this.audioUrl,
    this.voice,
    this.videoUrl,
    this.thumbnailUrl,
  });

  TutorModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      name = json['name'] as String?,
      title = json['title'] as String?,
      language = json['language'] as String?,
      imageUrl = json['image_url'] as String?,
      audioUrl = json['audio_url'] as String?,
      voice = json['voice'] as String?,
      videoUrl = json['video_url'] as String?,
      thumbnailUrl = json['thumbnail_url'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'title': title,
    'language': language,
    'image_url': imageUrl,
    'audio_url': audioUrl,
    'voice': voice,
    'video_url': videoUrl,
    'thumbnail_url': thumbnailUrl,
  };
}
