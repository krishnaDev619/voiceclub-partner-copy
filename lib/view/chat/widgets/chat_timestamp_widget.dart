import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';

class ChatTimestampWidget extends StatelessWidget {
  final DateTime timestamp;
  final bool sentByMe;
  final int chatGroupId;
  final Color color;
  final String messageId;

  const ChatTimestampWidget({
    super.key,
    required this.timestamp,
    required this.sentByMe,
    required this.chatGroupId,
    required this.messageId,
    this.color = const Color(0xFFF0F0F0),
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatMessagesController>(
      tag: chatGroupId.toString(),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          DateFormat.Hm().format(timestamp),
          style: TextStyle(
            height: 0.8,
            fontSize: FontSize.S,
            color: sentByMe ? color : const Color(0xFF999999),
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
        if (sentByMe)
          Obx(key: UniqueKey(), () {
            final lastSeenMessageId = controller.lastSeenMessageId.value;
            var isSeen = false;
            if (lastSeenMessageId != null && messageId.isNotEmpty) {
              isSeen =
                  (int.tryParse(messageId)! <=
                      int.tryParse(lastSeenMessageId)!);
            }
            return Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Icon(
                Icons.done_all_rounded,
                size: 14.0,
                applyTextScaling: true,
                color: isSeen ? Colors.lightBlueAccent : color,
              ),
            );
          }),
      ],
    );
  }
}
