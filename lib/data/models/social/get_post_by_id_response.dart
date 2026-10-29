import 'package:voiceclub_partner/data/models/social/post_model.dart';

class GetPostByIdResponseModel {
  final PostModel? post;

  GetPostByIdResponseModel({this.post});

  factory GetPostByIdResponseModel.fromJson(Map<String, dynamic> json) {
    return GetPostByIdResponseModel(post: PostModel.fromJson(json));
  }

  Map<String, dynamic> toJson() {
    return post?.toJson() ?? {};
  }
}
