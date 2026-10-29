class AcceptCallResponseModel {
  final String? message;
  final String? token;

  AcceptCallResponseModel({this.message, this.token});

  AcceptCallResponseModel.fromJson(Map<String, dynamic> json)
    : message = json['message'] as String?,
      token = json['token'] as String?;

  Map<String, dynamic> toJson() => {'message': message, 'token': token};
}
