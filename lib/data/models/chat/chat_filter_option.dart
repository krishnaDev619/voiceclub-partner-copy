class ChatFilterOption {
  final String? name;
  final String? code;

  ChatFilterOption({this.name, this.code});

  ChatFilterOption.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String?,
      code = json['code'] as String?;

  Map<String, dynamic> toJson() => {'name': name, 'code': code};
}
