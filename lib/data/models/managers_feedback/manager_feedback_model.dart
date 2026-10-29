import 'package:intl/intl.dart';

class ManagerFeedbackModel {
  final int? id;
  final int? kamId;
  final int? accountId;
  final String? audioUrl;
  final String? managerName;
  final bool? addressed;
  final String? createdAt;

  ManagerFeedbackModel({
    this.id,
    this.kamId,
    this.accountId,
    this.audioUrl,
    this.managerName,
    this.addressed,
    this.createdAt,
  });

  String get formattedCreatedAt {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(createdAt ?? ""));
  }

  ManagerFeedbackModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      kamId = json['kam_id'] as int?,
      accountId = json['account_id'] as int?,
      audioUrl = json['audio_url'] as String?,
      managerName = json['manager_name'] as String?,
      addressed = json['addressed'] as bool?,
      createdAt = json['created_at'] as String?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kam_id': kamId,
    'account_id': accountId,
    'audio_url': audioUrl,
    'manager_name': managerName,
    'addressed': addressed,
    'created_at': createdAt,
  };
}
