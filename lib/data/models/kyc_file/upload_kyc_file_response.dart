class UploadKYCFileResponseModel {
  final String? bucket;
  final String? file;

  UploadKYCFileResponseModel({this.bucket, this.file});

  UploadKYCFileResponseModel.fromJson(Map<String, dynamic> json)
    : bucket = json['bucket'] as String?,
      file = json['file'] as String?;

  Map<String, dynamic> toJson() => {'bucket': bucket, 'file': file};
}
