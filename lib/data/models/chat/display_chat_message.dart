import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/chat/chat_reply_message.dart';

class DisplayChatMessage extends Equatable {
  final String? id;
  final String? attachmentUrl;
  final String? content;
  final DateTime? createdAt;
  final String? externalId;
  final int? senderAccountId;
  final ChatType? type;
  final bool? isDeletedByPartner;
  final DateTime? updatedAt;
  final String? reaction;
  final ChatReplyMessage? replyMessage;
  final String? postId;

  const DisplayChatMessage({
    required this.id,
    required this.attachmentUrl,
    required this.content,
    required this.createdAt,
    required this.externalId,
    required this.senderAccountId,
    required this.type,
    required this.updatedAt,
    required this.isDeletedByPartner,
    required this.reaction,
    required this.replyMessage,
    required this.postId,
  });

  factory DisplayChatMessage.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    try {
      return DisplayChatMessage(
        id: documentId,
        attachmentUrl: data['AttachmentUrl'] ?? '',
        content: data['Content'] ?? '',
        createdAt: (data['CreatedAt'] as Timestamp).toDate(),
        externalId: data['ExternalId'] ?? '',
        senderAccountId: int.parse(data['SenderAccountId'] ?? '0'),
        type: ((data['Type'] as String?) ?? '').toChatType(),
        updatedAt: (data['UpdatedAt'] as Timestamp).toDate(),
        isDeletedByPartner: (data['IsDeletedByPartner'] as bool?) ?? false,
        reaction: data['Reaction'] ?? '',
        replyMessage:
            data['ReplyMessage'] != null
                ? ChatReplyMessage.fromJson(data['ReplyMessage'])
                : null,
        postId: data['PostId'] ?? '',
      );
    } catch (e) {
      Logger.logMessage(
        "DisplayChatMessage.fromFirestore: ${e.toString()} Id is $documentId",
      );
      return const DisplayChatMessage(
        id: '',
        attachmentUrl: '',
        content: '',
        createdAt: null,
        externalId: '',
        senderAccountId: 0,
        type: ChatType.ChatTypeText,
        updatedAt: null,
        isDeletedByPartner: false,
        reaction: '',
        replyMessage: null,
        postId: '',
      );
    }
  }

  @override
  List<Object?> get props => [id, createdAt, type];
}
