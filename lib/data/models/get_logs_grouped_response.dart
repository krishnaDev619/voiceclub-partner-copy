import 'package:voiceclub_partner/data/models/log.dart';

class GetLogsGroupedResponseModel {
  final List<LogModel>? logs;
  final int? missedCall;
  final int? busyCall;
  final int? offline;
  final int? views;
  final int? page;
  final int? totalItems;
  final int? totalPages;
  final String? message;

  GetLogsGroupedResponseModel({
    this.logs,
    this.missedCall,
    this.busyCall,
    this.offline,
    this.views,
    this.page,
    this.totalItems,
    this.totalPages,
    this.message,
  });

  GetLogsGroupedResponseModel.fromJson(Map<String, dynamic> json)
    : logs =
          (json['logs'] as List?)
              ?.map((dynamic e) => LogModel.fromJson(e as Map<String, dynamic>))
              .toList(),
      missedCall = json['missed_call'] as int?,
      busyCall = json['busy_call'] as int?,
      offline = json['offline'] as int?,
      views = json['views'] as int?,
      page = json['page'] as int?,
      totalItems = json['total_items'] as int?,
      totalPages = json['total_pages'] as int?,
      message = json['message'] as String?;

  Map<String, dynamic> toJson() => {
    'logs': logs?.map((e) => e.toJson()).toList(),
    'missed_call': missedCall,
    'busy_call': busyCall,
    'offline': offline,
    'views': views,
    'page': page,
    'total_items': totalItems,
    'total_pages': totalPages,
    'message': message,
  };
}
