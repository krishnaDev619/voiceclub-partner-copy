class Preset {
  final int? id;
  final String? text;

  Preset({this.id, this.text});

  Preset.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      text = json['text'] as String?;

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}
