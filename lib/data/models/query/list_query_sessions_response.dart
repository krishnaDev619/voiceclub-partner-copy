import 'package:voiceclub_partner/data/models/query/query_session.dart';

class ListQuerySessionsResponse {
  final List<QuerySession>? sessions;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  ListQuerySessionsResponse({
    this.sessions,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  ListQuerySessionsResponse.fromJson(Map<String, dynamic> json)
    : sessions =
          (json['sessions'] as List?)
              ?.map(
                (dynamic e) => QuerySession.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'sessions': sessions?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
