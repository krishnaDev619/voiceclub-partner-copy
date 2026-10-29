class IconDataModel {
  final String? unicode;
  final String? fontfamily;
  final String? fontPackage;

  IconDataModel({this.unicode, this.fontfamily, this.fontPackage});

  IconDataModel.fromJson(Map<String, dynamic> json)
    : unicode = json['unicode'] as String?,
      fontfamily = json['fontfamily'] as String?,
      fontPackage = json['fontPackage'] as String?;

  Map<String, dynamic> toJson() => {
    'unicode': unicode,
    'fontfamily': fontfamily,
    'fontPackage': fontPackage,
  };
}
