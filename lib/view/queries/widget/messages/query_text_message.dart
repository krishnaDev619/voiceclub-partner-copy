import 'package:flutter/material.dart';
import 'package:voiceclub_partner/data/models/query/query_message_model.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/markdown_text.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_message_action_content.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_timestamp_widget.dart';

class QueryTextMessage extends StatelessWidget {
  final QueryMessageModel message;
  final bool sentByMe;
  final bool showInteractiveActions;
  final Future<void> Function(
    String content,
    String? actionOptionType,
    String? actionValue,
    int? externalId,
  )?
  onSendActionReply;

  const QueryTextMessage({
    super.key,
    required this.message,
    required this.sentByMe,
    this.showInteractiveActions = false,
    this.onSendActionReply,
  });

  @override
  Widget build(BuildContext context) {
    final time = message.createdAt ?? DateTime.now();
    final text = message.content ?? '';
    final actionType = message.actionType?.trim();
    final showActions =
        showInteractiveActions &&
        onSendActionReply != null &&
        (actionType?.isNotEmpty ?? false);

    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: sentByMe ? const Color(0xFFD1FFCA) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12.0),
            topRight: const Radius.circular(12.0),
            bottomLeft:
                sentByMe
                    ? const Radius.circular(12.0)
                    : const Radius.circular(4.0),
            bottomRight:
                sentByMe
                    ? const Radius.circular(4.0)
                    : const Radius.circular(12.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child:
                      sentByMe
                          ? Text(
                            text.trim(),
                            style: const TextStyle(
                              fontSize: 13.0,
                              color: Colors.black87,
                              textBaseline: TextBaseline.alphabetic,
                            ),
                          )
                          : MarkdownText(text: text),
                ),
                const SizedBox(width: 8.0),
                QueryTimestampWidget(timestamp: time, sentByMe: sentByMe),
              ],
            ),
            if (showActions)
              QueryMessageActionContent(
                message: message,
                onSend: onSendActionReply!,
                embeddedInBubble: true,
              ),
          ],
        ),
      ),
    );
  }
}
