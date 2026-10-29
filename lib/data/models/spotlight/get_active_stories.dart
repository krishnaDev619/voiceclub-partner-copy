import 'package:voiceclub_partner/data/models/spotlight/stories.dart';

class GetActiveStoriesResponse {
  final List<Stories>? stories;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  GetActiveStoriesResponse({
    this.stories,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  GetActiveStoriesResponse.fromJson(Map<String, dynamic> json)
    : stories =
          (json['stories'] as List?)
              ?.map((dynamic e) => Stories.fromJson(e as Map<String, dynamic>))
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'stories': stories?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
