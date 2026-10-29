import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/firestore_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_reply_message.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_timestamp_widget.dart';
import 'package:voiceclub_partner/view/chat/widgets/messages/popup_menu_container.dart';
import 'package:voiceclub_partner/view/chat/widgets/messages/replied_message_widget.dart';

class ChatTextBubble extends StatelessWidget {
  final int chatGroupId;
  final String documentId;
  final String text;
  final DateTime time;
  final bool sentByMe;
  final ChatMember peerData;
  final ChatTheme theme;
  final ChatReplyMessage? replyMessage;
  final DisplayChatMessage message;

  const ChatTextBubble({
    super.key,
    required this.chatGroupId,
    required this.documentId,
    required this.text,
    required this.time,
    required this.sentByMe,
    required this.peerData,
    required this.theme,
    required this.message,
    this.replyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final vertical = replyMessage != null ? 6.0 : 8.0;
    final horizontal = replyMessage != null ? 6.0 : 12.0;
    final controller = Get.find<ChatMessagesController>(
      tag: chatGroupId.toString(),
    );
    final enabled =
        !sentByMe && !text.contains(FirestoreConstants.reportMessage);
    return PopupMenuContainer(
      reaction: message.reaction,
      message: message,
      sentByMe: sentByMe,
      onReport:
          enabled
              ? () {
                controller.onReportSelected(
                  message: message,
                  peerData: peerData,
                );
              }
              : null,
      onDelete:
          enabled
              ? () {
                controller.onDeleteSelected(
                  message: message,
                  peerData: peerData,
                );
              }
              : null,
      onCopy: () {
        controller.onCopySelected(text: text);
      },
      onReply:
          enabled
              ? () {
                controller.onReplySelected(message: message);
              }
              : null,
      onReactionSelected:
          enabled
              ? (reaction) {
                controller.onReactionSelected(
                  reaction: reaction,
                  peerData: peerData,
                  message: message,
                );
              }
              : null,
      enabled: true,
      child: Container(
        padding: EdgeInsets.symmetric(
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
              RepliedMessageWidget(
                replyMessage: replyMessage,
                theme: theme,
                chatGroupId: chatGroupId,
                peerName: peerData.user?.name ?? '',
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      text.trim(),
                      style: TextStyle(
                        color: sentByMe ? Colors.white : Colors.black,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  ChatTimestampWidget(
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
      ),
    );
  }
}
