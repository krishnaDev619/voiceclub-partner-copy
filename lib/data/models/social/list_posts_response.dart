import 'package:voiceclub_partner/data/models/social/post_model.dart';

class ListPostsResponseModel {
  final List<PostModel>? posts;
  final int? totalCount;
  final int? currentPage;
  final int? pageSize;
  final int? totalPages;

  ListPostsResponseModel({
    this.posts,
    this.totalCount,
    this.currentPage,
    this.pageSize,
    this.totalPages,
  });

  factory ListPostsResponseModel.fromJson(Map<String, dynamic> json) {
    return ListPostsResponseModel(
      posts:
          (json['posts'] as List<dynamic>?)
              ?.map((e) => PostModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalCount: json['total_count'] as int?,
      currentPage: json['current_page'] as int?,
      pageSize: json['page_size'] as int?,
      totalPages: json['total_pages'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts?.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
      'current_page': currentPage,
      'page_size': pageSize,
      'total_pages': totalPages,
    };
  }
}
