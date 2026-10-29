import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_reply_message.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';

class RepliedMessageWidget extends StatelessWidget {
  final ChatTheme theme;
  final int chatGroupId;
  final String peerName;
  final ChatReplyMessage? replyMessage;

  const RepliedMessageWidget({
    super.key,
    required this.theme,
    required this.chatGroupId,
    required this.peerName,
    this.replyMessage,
  });

  /// Get reply message text based on reply message type
  /// If the type is text then return the content
  /// If the type is Privacy Pack then return the privacy pack name
  /// If the type is Audio then return the "audio message"
  String get getReplyMessageText {
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
    final userController = Get.find<UserController>();

    return Obx(() {
      final userDetails = userController.userDetails.value;
      final name =
          replyMessage?.senderAccountId == userDetails.accountId
              ? userDetails.user?.name ?? "VoiceClub"
              : peerName;

      return Visibility(
        visible: replyMessage != null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: const Color(0xFFF6F5F3),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
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
                              replyMessage?.type == ChatType.ChatTypeAudio ||
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
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                DateFormat.Hm().format(
                  DateTime.tryParse(replyMessage?.createdAt ?? '') ??
                      DateTime.now(),
                ),
                style: const TextStyle(
                  fontSize: FontSize.S,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 4.0),
            ],
          ),
        ),
      );
    });
  }
}
