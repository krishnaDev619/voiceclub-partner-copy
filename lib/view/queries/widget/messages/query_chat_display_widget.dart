import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/query/query_message_model.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_audio_message.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_image_message.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_system_message.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_text_message.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_video_message.dart';

class QueryChatDisplayWidget extends StatelessWidget {
  final QueryMessageModel message;
  final bool sentByMe;
  final bool consecutive;
  final String? ticketId;
  final bool isLatestMessage;
  final Future<void> Function(
    String content,
    String? actionOptionType,
    String? actionValue,
    int? externalId,
  )
  onActionResponseSubmitted;

  const QueryChatDisplayWidget({
    super.key,
    required this.message,
    required this.sentByMe,
    this.consecutive = false,
    this.ticketId,
    required this.isLatestMessage,
    required this.onActionResponseSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size.width * 0.15;
    final alignment = sentByMe ? Alignment.centerRight : Alignment.centerLeft;
    final margin = EdgeInsets.only(
      top: consecutive ? 2.0 : 8.0,
      bottom: 2.0,
      left: sentByMe ? padding : 8.0,
      right: sentByMe ? 8.0 : padding,
    );

    if (message.senderType == QuerySenderType.SYSTEM) {
      return SystemMessage(
        message: message.content ?? '',
        margin: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      );
    }

    Widget messageWidget;

    switch (message.messageType) {
      case QueryMessageType.TEXT:
        if (message.content?.isNotEmpty ?? false) {
          messageWidget = QueryTextMessage(
            message: message,
            sentByMe: sentByMe,
            showInteractiveActions: isLatestMessage && !sentByMe,
            onSendActionReply: onActionResponseSubmitted,
          );
        } else {
          messageWidget = const SizedBox.shrink();
        }
        break;

      case QueryMessageType.IMAGE:
        if (message.attachment?.isNotEmpty ?? false) {
          messageWidget = QueryImageMessage(
            message: message,
            sentByMe: sentByMe,
          );
        } else {
          messageWidget = const SizedBox.shrink();
        }
        break;

      case QueryMessageType.AUDIO:
        if (message.attachment?.isNotEmpty ?? false) {
          messageWidget = QueryAudioMessage(
            message: message,
            sentByMe: sentByMe,
          );
        } else {
          messageWidget = const SizedBox.shrink();
        }
        break;

      case QueryMessageType.VIDEO:
        if (message.attachment?.isNotEmpty ?? false) {
          messageWidget = QueryVideoMessage(
            message: message,
            sentByMe: sentByMe,
          );
        } else {
          messageWidget = const SizedBox.shrink();
        }
        break;

      default:
        // Default to text message if type is unknown
        if (message.content?.isNotEmpty ?? false) {
          messageWidget = QueryTextMessage(
            message: message,
            sentByMe: sentByMe,
            showInteractiveActions: isLatestMessage && !sentByMe,
            onSendActionReply: onActionResponseSubmitted,
          );
        } else {
          messageWidget = const SizedBox.shrink();
        }
        break;
    }

    if (messageWidget is SizedBox) {
      return messageWidget;
    }

    return Container(
      margin: margin,
      alignment: alignment,
      child: messageWidget,
    );
  }
}
