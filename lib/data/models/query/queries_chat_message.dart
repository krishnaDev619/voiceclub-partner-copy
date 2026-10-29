import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';

class QueryChatMessage extends Equatable {
  final String? id;
  final String? content;
  final QueryMessageType? messageType;
  final QuerySenderType? senderType;
  final int? senderId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QueryChatMessage({
    required this.id,
    required this.content,
    required this.messageType,
    required this.senderType,
    this.senderId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QueryChatMessage.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return QueryChatMessage(
      id: documentId,
      content: data['Content'] ?? '',
      messageType: ((data['MessageType'] as String?) ?? '').toQueryMessage(),
      senderType: ((data['SenderType'] as String?) ?? '').toSenderType(),
      senderId:
          data['SenderAccountId'] != null &&
                  ((data['SenderAccountId'] as String?) != "")
              ? (int.parse((data['SenderAccountId'] as String? ?? "")))
              : null,
      createdAt: (data['CreatedAt'] as Timestamp).toDate(),
      updatedAt: (data['UpdatedAt'] as Timestamp).toDate(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    createdAt,
    messageType,
    senderType,
    updatedAt,
  ];
}
