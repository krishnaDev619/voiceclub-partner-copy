import 'package:voiceclub_partner/data/models/call_logs/call_log.dart';

class FetchCallLogsForPairResponseModel {
  final List<CallLog>? logs;
  final int? page;
  final int? totalItems;
  final int? totalPages;
  final String? message;

  FetchCallLogsForPairResponseModel({
    this.logs,
    this.page,
    this.totalItems,
    this.totalPages,
    this.message,
  });

  FetchCallLogsForPairResponseModel.fromJson(Map<String, dynamic> json)
    : logs =
          (json['logs'] as List?)
              ?.map((dynamic e) => CallLog.fromJson(e as Map<String, dynamic>))
              .toList(),
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?,
      message = json['message'] as String?;

  Map<String, dynamic> toJson() => {
    'logs': logs?.map((e) => e.toJson()).toList(),
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
    'message': message,
  };
}
