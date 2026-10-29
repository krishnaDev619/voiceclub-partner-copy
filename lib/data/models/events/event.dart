import 'package:voiceclub_partner/core/constants/enums.dart';

class Event {
  final int? id;
  final String? channelId;
  final String? messageId;
  final EventType? type;

  Event({this.id, this.channelId, this.messageId, this.type});

  Event.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      channelId = json['channel_id'].toString(),
      messageId = json['chat_message_id'].toString(),
      type = (json['type'] as String? ?? "").toEventType();

  Map<String, dynamic> toJson() => {
    'id': id,
    'channel_id': channelId,
    'chat_message_id': messageId,
    'type': type?.name,
  };
}
