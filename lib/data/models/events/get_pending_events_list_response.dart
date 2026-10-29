import 'package:voiceclub_partner/data/models/events/event.dart';

class GetPendingEventsListResponseModel {
  final List<Event>? events;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  GetPendingEventsListResponseModel({
    this.events,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  GetPendingEventsListResponseModel.fromJson(Map<String, dynamic> json)
    : events =
          (json['events'] as List?)
              ?.map((dynamic e) => Event.fromJson(e as Map<String, dynamic>))
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'events': events?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
