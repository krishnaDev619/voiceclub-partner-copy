class CreatePostResponseModel {
  final String? message;
  final String? postId;

  CreatePostResponseModel({this.message, this.postId});

  factory CreatePostResponseModel.fromJson(Map<String, dynamic> json) {
    return CreatePostResponseModel(
      message: json['message'] as String?,
      postId: json['post_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'message': message, 'post_id': postId};
}
