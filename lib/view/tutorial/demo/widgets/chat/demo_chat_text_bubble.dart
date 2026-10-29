import 'package:flutter/material.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_chat_timestamp_widget.dart';

class DemoChatTextBubble extends StatelessWidget {
  final int chatGroupId;
  final String documentId;
  final String text;
  final DateTime time;
  final bool sentByMe;
  final ChatMember peerData;
  final ChatTheme theme;
  final DisplayChatMessage message;

  const DemoChatTextBubble({
    super.key,
    required this.chatGroupId,
    required this.documentId,
    required this.text,
    required this.time,
    required this.sentByMe,
    required this.peerData,
    required this.theme,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    const vertical = 8.0;
    const horizontal = 12.0;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: vertical,
        horizontal: horizontal,
      ),
      decoration: BoxDecoration(
        color: sentByMe ? theme.primaryColor : theme.secondaryBubbleColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment:
              sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    text.trim(),
                    style: TextStyle(
                      color: sentByMe ? Colors.white : Colors.black,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
                DemoChatTimestampWidget(
                  key: UniqueKey(),
                  messageId: documentId,
                  sentByMe: sentByMe,
                  chatGroupId: chatGroupId,
                  timestamp: time,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
