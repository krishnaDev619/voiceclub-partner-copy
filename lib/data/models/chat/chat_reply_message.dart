import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';

class ChatReplyMessage extends Equatable {
  final String? id;
  final String? attachmentUrl;
  final String? content;
  final String? createdAt;
  final String? externalId;
  final int? senderAccountId;
  final ChatType? type;
  final bool? isDeletedByPartner;
  final String? updatedAt;
  final String? reaction;

  const ChatReplyMessage({
    this.id,
    this.attachmentUrl,
    this.content,
    this.createdAt,
    this.externalId,
    this.senderAccountId,
    this.type,
    this.updatedAt,
    this.isDeletedByPartner,
    this.reaction,
  });

  factory ChatReplyMessage.fromJson(Map<String, dynamic> data) {
    return ChatReplyMessage(
      id: data['Id'] ?? '',
      attachmentUrl: data['AttachmentUrl'] ?? '',
      content: data['Content'] ?? '',
      createdAt: (data['CreatedAt'] ?? ''),
      externalId: data['ExternalId'] ?? '',
      senderAccountId: int.parse(data['SenderAccountId'] ?? '0'),
      type: ((data['Type'] as String?) ?? '').toChatType(),
      updatedAt: (data['UpdatedAt'] ?? ''),
      isDeletedByPartner: (data['IsDeletedByPartner'] as bool?) ?? false,
      reaction: data['Reaction'] ?? '',
    );
  }

  factory ChatReplyMessage.fromDisplayChatMessage(DisplayChatMessage message) {
    return ChatReplyMessage(
      id: message.id,
      attachmentUrl: message.attachmentUrl ?? '',
      content: message.content ?? '',
      createdAt: message.createdAt?.toIso8601String(),
      externalId: message.externalId,
      senderAccountId: message.senderAccountId,
      type: message.type,
      updatedAt: message.updatedAt?.toIso8601String(),
      isDeletedByPartner: message.isDeletedByPartner,
      reaction: message.reaction,
    );
  }

  /// To json method
  Map<String, dynamic> toJson() => {
    'Id': id,
    'AttachmentUrl': attachmentUrl,
    'Content': content,
    'CreatedAt': createdAt,
    'ExternalId': externalId.toString(),
    'SenderAccountId': senderAccountId.toString(),
    'Type': type?.toChatTypeString(),
    'UpdatedAt': updatedAt,
    'IsDeletedByPartner': isDeletedByPartner,
    'Reaction': reaction,
  };

  @override
  List<Object?> get props => [id, createdAt, type];
}
