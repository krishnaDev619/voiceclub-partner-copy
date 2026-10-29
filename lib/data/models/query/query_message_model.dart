import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/query/action_choice.dart';

class QueryMessageModel extends Equatable {
  final String? id;
  final String? attachment;
  final String? content;
  final String? actionType;
  final DateTime? createdAt;
  final QueryMessageType? messageType;
  final int? senderAccountId;
  final QuerySenderType? senderType;
  final DateTime? updatedAt;
  final List<ActionChoice>? actionChoices;

  const QueryMessageModel({
    this.id,
    this.attachment,
    this.content,
    this.actionType,
    this.createdAt,
    this.messageType,
    this.senderAccountId,
    this.senderType,
    this.updatedAt,
    this.actionChoices,
  });

  factory QueryMessageModel.fromFirestore(Map<String, dynamic> data) {
    return QueryMessageModel(
      id: data['ID'] ?? data['id'] as String?,
      attachment:
          data['Attachment'] as String? ?? data['attachment'] as String?,
      content: data['Content'] ?? '',
      actionType: data['Action'] ?? data['action'] as String?,
      messageType: ((data['MessageType'] as String?) ?? '').toQueryMessage(),
      senderType: ((data['SenderType'] as String?) ?? '').toSenderType(),
      senderAccountId:
          data['SenderAccountId'] != null &&
                  ((data['SenderAccountId'] as String?) != "")
              ? (int.tryParse((data['SenderAccountId'] as String? ?? "")))
              : null,
      createdAt: (data['CreatedAt'] as Timestamp).toDate(),
      updatedAt: (data['UpdatedAt'] as Timestamp).toDate(),
      actionChoices:
          (data['Options'] as List?)
              ?.map((e) => ActionChoice.fromJson(e))
              .toList(),
    );
  }

  QueryMessageModel.fromJson(Map<String, dynamic> json)
    : id = json['ID'] as String? ?? json['id'] as String?,
      attachment =
          json['Attachment'] as String? ?? json['attachment'] as String?,
      content = json['Content'] as String? ?? json['content'] as String?,
      actionType = json['Action'] ?? json['action'] as String?,
      createdAt = _convertToDateTime(json['created_at'] ?? json['CreatedAt']),
      messageType =
          (json['MessageType'] as String? ?? json['message_type'] as String?)
              ?.toQueryMessage(),
      senderAccountId =
          json['SenderAccountId'] != null
              ? (json['SenderAccountId'] is String
                  ? int.tryParse(json['SenderAccountId'] as String)
                  : json['SenderAccountId'] as int?)
              : (json['sender_account_id'] as int?),
      senderType =
          (json['SenderType'] as String? ?? json['sender_type'] as String?)
              ?.toSenderType(),
      actionChoices =
          (json['Options'] as List?)
              ?.map((e) => ActionChoice.fromJson(e))
              .toList(),
      updatedAt = _convertToDateTime(json['updated_at'] ?? json['UpdatedAt']);

  Map<String, dynamic> toJson() => {
    'ID': id,
    'Attachment': attachment,
    'Content': content,
    'Action': actionType,
    'CreatedAt': createdAt?.toIso8601String(),
    'MessageType': messageType?.toQueryMessageTypeString(),
    'SenderAccountId': senderAccountId?.toString(),
    'SenderType': senderType?.querySenderTypeToString(),
    'UpdatedAt': updatedAt?.toIso8601String(),
    'Options': actionChoices?.map((e) => e.toJson()).toList(),
  };

  static DateTime _convertToDateTime(dynamic timestamp) {
    if (timestamp == null) {
      return DateTime.now();
    }

    // If it's already a DateTime, return it
    if (timestamp is DateTime) {
      return timestamp;
    }

    // If it's a Firebase Timestamp, convert it to DateTime
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }

    // If it's a String, try to parse it
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return DateTime.now();
      }
    }

    // Fallback: return current DateTime
    return DateTime.now();
  }

  @override
  List<Object?> get props => [
    id,
    attachment,
    content,
    actionType,
    createdAt,
    messageType,
    senderAccountId,
    senderType,
    updatedAt,
    actionChoices,
  ];
}
