import 'package:voiceclub_partner/data/models/social/comment_model.dart';

class ListCommentsResponseModel {
  final List<CommentModel>? comments;
  final int? totalCount;
  final int? currentPage;
  final int? pageSize;
  final int? totalPages;

  ListCommentsResponseModel({
    required this.comments,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
  });

  factory ListCommentsResponseModel.fromJson(Map<String, dynamic> json) {
    return ListCommentsResponseModel(
      comments:
          json['comments'] != null
              ? (json['comments'] as List<dynamic>)
                  .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
                  .toList()
              : null,
      totalCount: json['total_count'] as int?,
      currentPage: json['current_page'] as int?,
      pageSize: json['page_size'] as int?,
      totalPages: json['total_pages'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comments': comments?.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
      'current_page': currentPage,
      'page_size': pageSize,
      'total_pages': totalPages,
    };
  }
}
