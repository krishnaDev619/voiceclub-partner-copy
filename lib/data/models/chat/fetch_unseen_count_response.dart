class FetchUnseenCountResponseModel {
  final int? count;
  final String? message;

  FetchUnseenCountResponseModel({this.count, this.message});

  FetchUnseenCountResponseModel.fromJson(Map<String, dynamic> json)
    : count = json['count'] as int?,
      message = json['message'] as String?;

  Map<String, dynamic> toJson() => {'count': count, 'message': message};
}
