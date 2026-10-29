class UnsplashPhoto {
  final String? id;
  final String? url;
  final String? thumbUrl;
  final String? description;

  const UnsplashPhoto({this.id, this.url, this.thumbUrl, this.description});

  factory UnsplashPhoto.fromJson(Map<String, dynamic> json) {
    return UnsplashPhoto(
      id: json['id'] as String?,
      url: json['urls']['regular'] as String?,
      thumbUrl: json['urls']['thumb'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'urls': {'regular': url, 'thumb': thumbUrl},
      'description': description,
    };
  }
}
