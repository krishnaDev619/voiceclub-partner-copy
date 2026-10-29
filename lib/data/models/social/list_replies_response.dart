import 'package:voiceclub_partner/data/models/social/reply_model.dart';

class ListRepliesResponseModel {
  final List<ReplyModel>? replies;
  final int? totalCount;
  final int? currentPage;
  final int? pageSize;
  final int? totalPages;

  ListRepliesResponseModel({
    this.replies,
    this.totalCount,
    this.currentPage,
    this.pageSize,
    this.totalPages,
  });

  factory ListRepliesResponseModel.fromJson(Map<String, dynamic> json) {
    return ListRepliesResponseModel(
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((e) => ReplyModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      totalCount: json['total_count'] as int?,
      currentPage: json['current_page'] as int?,
      pageSize: json['page_size'] as int?,
      totalPages: json['total_pages'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'replies': replies?.map((e) => e.toJson()).toList(),
      'total_count': totalCount,
      'current_page': currentPage,
      'page_size': pageSize,
      'total_pages': totalPages,
    };
  }
}
