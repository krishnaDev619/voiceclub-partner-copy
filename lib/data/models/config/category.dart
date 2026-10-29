class CategoryModel {
  final String? displayName;
  final String? categoryCode;

  CategoryModel({this.displayName, this.categoryCode});

  CategoryModel.fromJson(Map<String, dynamic> json)
    : displayName = json['display_name'] as String?,
      categoryCode = json['category_code'] as String?;

  Map<String, dynamic> toJson() => {
    'display_name': displayName,
    'category_code': categoryCode,
  };
}
