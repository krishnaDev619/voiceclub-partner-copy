class UploadFileResponseModel {
  final String? bucket;
  final String? file;

  UploadFileResponseModel({this.bucket, this.file});

  UploadFileResponseModel.fromJson(Map<String, dynamic> json)
    : bucket = json['bucket'] as String?,
      file = json['file'] as String?;

  Map<String, dynamic> toJson() => {'bucket': bucket, 'file': file};
}
