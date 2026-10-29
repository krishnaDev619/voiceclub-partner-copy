import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_timestamp_widget.dart';
import 'package:voiceclub_partner/view/chat/widgets/messages/popup_menu_container.dart';
import 'package:voiceclub_partner/view/chat/widgets/messages/replied_message_widget.dart';

class ChatStickerMessage extends StatelessWidget {
  const ChatStickerMessage({
    super.key,
    required this.supply,
    required this.demand,
    required this.sentByMe,
    required this.stickerUrl,
    required this.time,
    required this.chatGroupId,
    required this.message,
    required this.theme,
    required this.documentId,
  });

  final ChatMember demand, supply;
  final bool sentByMe;
  final String stickerUrl;
  final DateTime time;
  final int chatGroupId;
  final DisplayChatMessage message;
  final ChatTheme theme;
  final String documentId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatMessagesController>(
      tag: chatGroupId.toString(),
    );
    return PopupMenuContainer(
      reaction: message.reaction,
      message: message,
      enabled: !sentByMe,
      sentByMe: sentByMe,
      onReactionSelected: (reaction) {
        controller.onReactionSelected(
          message: message,
          reaction: reaction,
          peerData: demand,
        );
      },
      onReply: () {
        controller.onReplySelected(message: message);
      },
      child: IntrinsicWidth(
        child: Container(
          decoration:
              message.replyMessage != null
                  ? BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(12.0),
                  )
                  : null,
          padding:
              message.replyMessage != null ? const EdgeInsets.all(6.0) : null,
          child: Column(
            crossAxisAlignment:
                sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              RepliedMessageWidget(
                replyMessage: message.replyMessage,
                theme: theme,
                chatGroupId: chatGroupId,
                peerName: demand.user?.name ?? '',
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: sentByMe ? 0.0 : 4.0,
                  right: sentByMe ? 4.0 : 0.0,
                  bottom: 4.0,
                ),
                child: Text(
                  sentByMe
                      ? 'You sent ${supply.user?.name} a sticker'
                      : '${demand.user?.name} sent you a sticker',
                  maxLines: 2,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    fontSize: FontSize.M,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  height: 80.0,
                  child: FastCachedImage(url: stickerUrl),
                ),
              ),
              ChatTimestampWidget(
                key: UniqueKey(),
                timestamp: time,
                sentByMe: sentByMe,
                chatGroupId: chatGroupId,
                messageId: documentId,
                color:
                    message.replyMessage != null
                        ? Colors.white
                        : const Color(0xFF999999),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
