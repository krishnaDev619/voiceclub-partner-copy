import 'package:voiceclub_partner/data/models/spotlight/engagements.dart';

class GetStoryEngagementsResponse {
  final List<Engagements>? engagements;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  GetStoryEngagementsResponse({
    this.engagements,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  GetStoryEngagementsResponse.fromJson(Map<String, dynamic> json)
    : engagements =
          (json['engagements'] as List?)
              ?.map(
                (dynamic e) => Engagements.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'engagements': engagements?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
