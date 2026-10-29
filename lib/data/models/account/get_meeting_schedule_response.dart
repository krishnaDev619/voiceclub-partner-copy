import 'package:voiceclub_partner/data/models/account/meeting.dart';

class GetMeetingScheduleResponseModel {
  final List<Meeting>? meetings;
  final int? page;
  final int? totalItems;
  final int? totalPages;

  GetMeetingScheduleResponseModel({
    this.meetings,
    this.page,
    this.totalItems,
    this.totalPages,
  });

  GetMeetingScheduleResponseModel.fromJson(Map<String, dynamic> json)
    : meetings =
          (json['meetings'] as List?)
              ?.map((dynamic e) => Meeting.fromJson(e as Map<String, dynamic>))
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?;

  Map<String, dynamic> toJson() => {
    'meetings': meetings?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
  };
}
