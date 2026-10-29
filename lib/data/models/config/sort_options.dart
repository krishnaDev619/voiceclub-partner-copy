class SortOptionsModel {
  final String? name;
  final int? value;

  SortOptionsModel({this.name, this.value});

  SortOptionsModel.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String?,
      value = json['value'] as int?;

  Map<String, dynamic> toJson() => {'name': name, 'value': value};
}
