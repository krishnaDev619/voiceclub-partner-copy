class GetFileUrlResponseModel {
  final String? url;

  GetFileUrlResponseModel({this.url});

  GetFileUrlResponseModel.fromJson(Map<String, dynamic> json)
    : url = json['url'] as String?;

  Map<String, dynamic> toJson() => {'url': url};
}
