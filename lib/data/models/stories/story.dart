class StoryData {
  final int? id;
  final String? mediaUrl;
  final String? mediaType;
  final String? color;
  final String? createdAt;

  StoryData({
    this.id,
    this.mediaUrl,
    this.mediaType,
    this.color,
    this.createdAt,
  });

  StoryData.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      mediaUrl = json['media_url'] as String?,
      mediaType = json['media_type'] as String?,
      color = json['color'] as String?,
      createdAt = json['created_at'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'media_url': mediaUrl,
    'media_type': mediaType,
    'color': color,
    'created_at': createdAt,
  };
}
