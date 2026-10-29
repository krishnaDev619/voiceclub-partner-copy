import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';

class ChatMessageWidget extends StatefulWidget {
  final EdgeInsets margin;
  final Alignment alignment;
  final Widget messageWidget;
  final DisplayChatMessage message;
  final int groupId;
  final bool sentByMe;
  final ChatMember peerData;
  final ChatTheme theme;

  const ChatMessageWidget({
    super.key,
    required this.margin,
    required this.alignment,
    required this.messageWidget,
    required this.message,
    required this.groupId,
    required this.sentByMe,
    required this.peerData,
    required this.theme,
  });

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  double _dragOffset = 0.0;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final messageType = widget.message.type;
    // Only allow this types to swipe to reply
    if (messageType == ChatType.ChatTypeAudio ||
        messageType == ChatType.ChatTypeGift ||
        messageType == ChatType.ChatTypeSticker ||
        messageType == ChatType.ChatTypeText ||
        messageType == ChatType.ChatTypePrivacyPack) {
      if (widget.sentByMe) {
        // Return if the user is swiping right
        if (!details.delta.dx.isNegative) {
          return;
        }
      } else {
        // Return if the user is swiping left
        if (details.delta.dx.isNegative) {
          return;
        }
      }

      if (_dragOffset > 180 || _dragOffset < -180) {
        HapticFeedback.vibrate();
        _dragOffset = 0.0;
        Get.find<ChatMessagesController>(
          tag: widget.groupId.toString(),
        ).updateReplyMessage(widget.message);
      } else {
        _dragOffset += details.delta.dx;
      }

      setState(() {});
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    setState(() {
      _dragOffset = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(_dragOffset, 0, 0),
        child: Column(
          crossAxisAlignment:
              widget.alignment == Alignment.centerLeft
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: widget.key,
              margin: widget.margin,
              alignment: widget.alignment,
              child: widget.messageWidget,
            ),
          ],
        ),
      ),
    );
  }
}
