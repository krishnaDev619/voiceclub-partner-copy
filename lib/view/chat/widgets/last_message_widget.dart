import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_message.dart';

class LastMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool seen;
  final bool isMe;
  final String senderName;

  const LastMessageWidget({
    super.key,
    required this.message,
    required this.seen,
    required this.isMe,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    final messageColor = seen ? const Color(0xFF999999) : Colors.black;
    final messageTextStyle = TextStyle(
      color: messageColor,
      fontWeight: seen ? Weight.normal : Weight.bold,
    );

    Widget? messageIcon;
    String messageText;

    switch (message.type) {
      case ChatType.ChatTypeAudio:
        messageIcon = Icon(Icons.mic, size: 16.0, color: messageColor);
        messageText = 'Audio';
        break;
      case ChatType.ChatTypeAudioNotification:
        messageIcon = Icon(
          Icons.notifications_none_rounded,
          size: 16.0,
          color: messageColor,
        );
        messageText = 'You sent an audio notification';
        break;
      case ChatType.ChatTypeNotification:
        messageIcon = Icon(
          Icons.notifications_none_rounded,
          size: 16.0,
          color: messageColor,
        );
        messageText = 'You sent a notification';
        break;
      case ChatType.ChatTypeCall:
        messageIcon = Icon(Icons.call, size: 16.0, color: messageColor);
        messageText = 'Call with $senderName';
        break;
      case ChatType.ChatTypeGift:
        messageText = '${isMe ? 'You' : senderName} sent a sticker';
        break;
      case ChatType.ChatTypeSticker:
        messageText = '${isMe ? 'You' : senderName} sent a sticker';
        break;
      case ChatType.ChatTypeImage:
        messageIcon = Icon(
          Icons.camera_alt_rounded,
          size: 16.0,
          color: messageColor,
        );
        messageText = 'Image';
        break;
      case ChatType.ChatTypeViewedCall:
        messageIcon = const Icon(
          Icons.phone_missed_rounded,
          size: 16.0,
          color: Colors.amber,
        );
        messageText = 'Missed call (no penalty)';
        break;
      case ChatType.ChatTypeMissedCall:
        messageIcon = const Icon(
          Icons.phone_missed_rounded,
          size: 16.0,
          color: Colors.red,
        );
        messageText = 'Missed call';
        break;
      case ChatType.ChatTypeStoryReply:
        messageText = 'Reacted to your story';
        break;
      case ChatType.ChatTypeText:
        messageText = message.content ?? '';
        break;
      case ChatType.ChatTypePrivacyPack:
        messageText = 'You sent Privacy Pack';
        break;
      case ChatType.ChatTypePostComment:
        messageIcon = Icon(Icons.comment, size: 16.0, color: messageColor);
        messageText =
            isMe ? "You commented on their post" : "Commented on your post";
        break;
      case ChatType.ChatTypeVideo:
        messageIcon = Icon(
          Icons.camera_alt_rounded,
          size: 16.0,
          color: messageColor,
        );
        messageText = 'Sent a video';
        break;
      default:
        messageText = message.content ?? '';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (messageIcon != null) ...[messageIcon, const SizedBox(width: 4.0)],
          Flexible(
            child: Text(
              messageText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: messageTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
