class CleanVoiceUploadResponseModel {
  final String signedUrl;

  CleanVoiceUploadResponseModel({required this.signedUrl});

  CleanVoiceUploadResponseModel.fromJson(Map<String, dynamic> json)
    : signedUrl = json['signedUrl'] as String;

  Map<String, dynamic> toJson() => {'signedUrl': signedUrl};
}
