import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';

class ReplyMessageWidget extends StatelessWidget {
  final ChatTheme theme;
  final int chatGroupId;
  final String peerName;

  const ReplyMessageWidget({
    super.key,
    required this.theme,
    required this.chatGroupId,
    required this.peerName,
  });

  /// Get reply message text based on reply message type
  /// If the type is text then return the content
  /// If the type is Privacy Pack then return the privacy pack name
  /// If the type is Audio then return the "audio message"
  String get getReplyMessageText {
    final replyMessage =
        Get.find<ChatMessagesController>(
          tag: chatGroupId.toString(),
        ).replyMessage.value;
    switch (replyMessage?.type) {
      case ChatType.ChatTypeText:
        return replyMessage?.content ?? "";
      case ChatType.ChatTypePrivacyPack:
        return "Privacy Pack";
      case ChatType.ChatTypeAudio:
      case ChatType.ChatTypeCall:
        return "Audio Message";
      default:
        return "Reply message";
    }
  }

  Widget get getContentWidget {
    final replyMessage =
        Get.find<ChatMessagesController>(
          tag: chatGroupId.toString(),
        ).replyMessage.value;
    switch (replyMessage?.type) {
      case ChatType.ChatTypeText:
      case ChatType.ChatTypeAudio:
      case ChatType.ChatTypeCall:
        return Expanded(
          child: Text(
            getReplyMessageText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),
        );
      case ChatType.ChatTypeGift:
      case ChatType.ChatTypeSticker:
        return SizedBox(
          height: 50.0,
          child: FastCachedImage(url: replyMessage?.attachmentUrl ?? ''),
        );
      default:
        return Expanded(
          child: Text(
            getReplyMessageText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ChatMessagesController>(
      tag: chatGroupId.toString(),
    )) {
      return const SizedBox.shrink();
    }
    final controller = Get.find<ChatMessagesController>(
      tag: chatGroupId.toString(),
    );

    final userController = Get.find<UserController>();

    return Obx(() {
      final userDetails = userController.userDetails.value;
      final replyMessage = controller.replyMessage.value;
      final name =
          replyMessage?.senderAccountId == userDetails.accountId
              ? userDetails.user?.name ?? "VoiceClub"
              : peerName;
      // print("Reply Message: ${replyMessage?.createdAt}");

      return Visibility(
        visible: replyMessage != null,
        child: IntrinsicHeight(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  color: const Color(0xFFF6F5F3),
                  border: Border(
                    left: BorderSide(color: theme.primaryColor, width: 6.0),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              Visibility(
                                visible:
                                    replyMessage?.type ==
                                        ChatType.ChatTypeAudio ||
                                    replyMessage?.type == ChatType.ChatTypeCall,
                                child: const Padding(
                                  padding: EdgeInsets.only(right: 4.0),
                                  child: Icon(
                                    Icons.mic,
                                    size: 18.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              getContentWidget,
                            ],
                          ),
                          const SizedBox(height: 8.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 6.0,
                top: 6.0,
                child: GestureDetector(
                  onTap: () {
                    controller.removeReplyMessage();
                  },
                  child: const Icon(
                    Icons.close,
                    size: 22.0,
                    color: Color(0xFF7F7F7F),
                  ),
                ),
              ),
              Positioned(
                right: 6.0,
                bottom: 10.0,
                child: Text(
                  DateFormat.Hm().format(
                    DateTime.tryParse(replyMessage?.createdAt ?? '') ??
                        DateTime.now(),
                  ),
                  style: const TextStyle(
                    fontSize: FontSize.S,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
