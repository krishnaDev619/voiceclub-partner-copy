import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 3)
class ChatMessage {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final int? senderAccountId;
  @HiveField(2)
  final String? content;
  @HiveField(3)
  final String? attachmentUrl;
  @HiveField(4)
  final ChatType? type;
  @HiveField(5)
  final int? linkedItemId;

  ChatMessage({
    this.id,
    this.senderAccountId,
    this.content,
    this.attachmentUrl,
    this.type,
    this.linkedItemId,
  });

  ChatMessage.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      senderAccountId = json['sender_account_id'] as int?,
      content = json['content'] as String?,
      attachmentUrl = json['attachment_url'] as String?,
      type = (json['type'] as String? ?? '').toChatType(),
      linkedItemId = json['linked_item_id'] as int?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender_account_id': senderAccountId,
    'content': content,
    'attachment_url': attachmentUrl,
    'type': type?.toChatTypeString() ?? '',
    'linked_item_id': linkedItemId,
  };
}
