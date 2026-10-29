class VerifyOtpResponseModel {
  final String? accessToken;

  VerifyOtpResponseModel({this.accessToken});

  VerifyOtpResponseModel.fromJson(Map<String, dynamic> json)
    : accessToken = json['access_token'] as String?;

  Map<String, dynamic> toJson() => {'access_token': accessToken};
}
