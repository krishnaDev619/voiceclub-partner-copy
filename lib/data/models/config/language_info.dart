class LanguageInfo {
  final String? code;
  final String? description;
  final String? icon;
  final String? color;

  LanguageInfo({this.code, this.description, this.icon, this.color});

  LanguageInfo.fromJson(Map<String, dynamic> json)
    : code = json['code'] as String?,
      description = json['description'] as String?,
      color = json['color'] as String?,
      icon = json['icon'] as String?;

  Map<String, dynamic> toJson() => {
    'code': code,
    'description': description,
    'icon': icon,
    'color': color,
  };
}
