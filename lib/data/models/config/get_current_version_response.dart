class GetCurrentVersionModel {
  String? version;
  String? message;

  GetCurrentVersionModel({this.version, this.message});

  GetCurrentVersionModel.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['version'] = version;
    data['message'] = message;
    return data;
  }
}
