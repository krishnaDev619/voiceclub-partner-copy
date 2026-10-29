class BaseResponseModel {
  final String? message;

  BaseResponseModel({this.message});

  BaseResponseModel.fromJson(Map<String, dynamic> json)
    : message = json['message'] as String?;

  Map<String, dynamic> toJson() => {'message': message};
}
