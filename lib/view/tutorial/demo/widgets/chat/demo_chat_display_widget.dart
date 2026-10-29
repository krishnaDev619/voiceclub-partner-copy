import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_chat_audio_message.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_chat_audio_notification_message.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_chat_notification_message.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_chat_sticker_message.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_chat_text_bubble.dart';

class DemoChatDisplayWidget extends StatefulWidget {
  final DisplayChatMessage message;
  final int groupId;
  final bool sentByMe, consecutive;
  final CategoryCode categoryCode;
  final ChatMember peerData;
  final ChatMember myData;
  final ChatTier tier;
  final bool isLatestMessage;
  final ChatTheme theme;

  const DemoChatDisplayWidget({
    super.key,
    required this.message,
    required this.groupId,
    required this.categoryCode,
    required this.consecutive,
    required this.sentByMe,
    required this.peerData,
    required this.myData,
    required this.tier,
    required this.isLatestMessage,
    required this.theme,
  });

  @override
  State<DemoChatDisplayWidget> createState() => _DemoChatDisplayWidgetState();
}

class _DemoChatDisplayWidgetState extends State<DemoChatDisplayWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final time = widget.message.createdAt ?? DateTime.now();
    final padding = MediaQuery.of(context).size.width / 5;
    final alignment =
        widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft;
    final margin = EdgeInsets.only(
      top: widget.consecutive ? 4.0 : 12.0,
      left: widget.sentByMe ? padding : 8.0,
      right: widget.sentByMe ? 8.0 : padding,
    );

    Widget messageWidget = const SizedBox.shrink();

    switch (widget.message.type) {
      case ChatType.ChatTypeAudio:
        if (widget.message.attachmentUrl?.isNotEmpty ?? false) {
          double waveformWidth =
              MediaQuery.of(context).size.width * 0.65 - 32.0;

          messageWidget = DemoChatAudioMessage(
            key: widget.key,
            time: time,
            groupId: widget.groupId,
            width: waveformWidth,
            sentByMe: widget.sentByMe,
            audioUrl: widget.message.attachmentUrl!,
            theme: widget.theme,
            peer: widget.peerData,
            documentId: widget.message.id ?? "",
            message: widget.message,
          );
        }
        break;
      case ChatType.ChatTypeAudioNotification:
        if (widget.message.attachmentUrl?.isNotEmpty ?? false) {
          messageWidget = DemoChatAudioNotificationMessage(
            key: widget.key,
            time: time,
            groupId: widget.groupId,
            categoryCode: widget.categoryCode,
            demand: widget.sentByMe ? widget.peerData : widget.myData,
            supply: widget.sentByMe ? widget.myData : widget.peerData,
            sentByMe: widget.sentByMe,
            audioUrl: widget.message.attachmentUrl!,
            isNotification: true,
            theme: widget.theme,
            message: widget.message,
          );
        }
        break;
      case ChatType.ChatTypeNotification:
        messageWidget = DemoChatNotificationMessage(
          key: widget.key,
          time: time,
          sentByMe: widget.sentByMe,
          supply: widget.sentByMe ? widget.myData : widget.peerData,
          demand: widget.sentByMe ? widget.peerData : widget.myData,
          categoryCode: widget.categoryCode,
        );
        break;
      case ChatType.ChatTypeGift:
        if (widget.message.attachmentUrl?.isNotEmpty ?? false) {
          messageWidget = DemoChatStickerMessage(
            key: widget.key,
            supply: widget.sentByMe ? widget.peerData : widget.myData,
            demand: widget.sentByMe ? widget.myData : widget.peerData,
            sentByMe: widget.sentByMe,
            stickerUrl: widget.message.attachmentUrl!,
            time: time,
            chatGroupId: widget.groupId,
            message: widget.message,
            theme: widget.theme,
            documentId: widget.message.id ?? "",
          );
        }
        break;
      case ChatType.ChatTypeSticker:
        if (widget.message.attachmentUrl?.isNotEmpty ?? false) {
          messageWidget = DemoChatStickerMessage(
            key: widget.key,
            supply: widget.sentByMe ? widget.peerData : widget.myData,
            demand: widget.sentByMe ? widget.myData : widget.peerData,
            sentByMe: widget.sentByMe,
            stickerUrl: widget.message.attachmentUrl!,
            time: time,
            chatGroupId: widget.groupId,
            message: widget.message,
            theme: widget.theme,
            documentId: widget.message.id ?? "",
          );
        }
        break;
      case ChatType.ChatTypeText:
        if (widget.message.content?.isNotEmpty ?? false) {
          messageWidget = DemoChatTextBubble(
            key: widget.key,
            documentId: widget.message.id ?? "",
            chatGroupId: widget.groupId,
            text: widget.message.content ?? '',
            time: time,
            peerData: widget.peerData,
            sentByMe: widget.sentByMe,
            theme: widget.theme,
            message: widget.message,
          );
        }
        break;
      default:
        break;
    }

    if (widget.message.type == ChatType.ChatTypeMissedCall ||
        widget.message.type == ChatType.ChatTypeViewedCall ||
        widget.message.type == ChatType.ChatTypeNotification) {
      return messageWidget;
    } else {
      return messageWidget != const SizedBox.shrink()
          ? Container(
            key: widget.key,
            margin: margin,
            alignment: alignment,
            child: messageWidget,
          )
          : const SizedBox.shrink();
    }
  }

  @override
  bool get wantKeepAlive => true;
}
