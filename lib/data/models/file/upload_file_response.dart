class FileResponseModel {
  final String? url;

  FileResponseModel({this.url});

  FileResponseModel.fromJson(Map<String, dynamic> json)
    : url = json['url'] as String?;

  Map<String, dynamic> toJson() => {'url': url};
}
