class GiftData {
  final int? id;
  final String? stickerUrl;

  GiftData({this.id, this.stickerUrl});

  GiftData.fromJson(Map<String, dynamic> json)
    : id = json['sticker_id'] as int?,
      stickerUrl = json['sticker_url'] as String?;

  Map<String, dynamic> toJson() => {
    'sticker_id': id,
    'sticker_url': stickerUrl,
  };
}
