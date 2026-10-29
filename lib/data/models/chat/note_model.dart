class Note {
  final String? text;
  final String? createdAt;

  Note({this.text, this.createdAt});

  Note.fromJson(Map<String, dynamic> json)
    : text = json['text'] as String?,
      createdAt = json['created_at'] as String?;

  Map<String, dynamic> toJson() => {'text': text, 'created_at': createdAt};
}
