import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_timestamp_widget.dart';
import 'package:voiceclub_partner/view/social/view_post_screen.dart';

class ChatPostCommentMessage extends StatelessWidget {
  final ChatMember demand, supply;
  final bool sentByMe;
  final String comment;
  final DateTime time;
  final String postId;
  final ChatTheme theme;
  final int chatGroupId;
  final String messageId;

  const ChatPostCommentMessage({
    super.key,
    required this.demand,
    required this.supply,
    required this.sentByMe,
    required this.comment,
    required this.time,
    required this.theme,
    required this.postId,
    required this.chatGroupId,
    required this.messageId,
  });

  void _handleTap() {
    Get.to(() => ViewPostScreen(postId: postId));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Column(
        crossAxisAlignment:
            sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: sentByMe ? 0.0 : 4.0,
              right: sentByMe ? 4.0 : 0.0,
              bottom: 4.0,
            ),
            child: Text(
              sentByMe
                  ? 'You commented on ${supply.user?.name}\'s post'
                  : '${demand.user?.name} commented on your post',
              maxLines: 2,
              overflow: TextOverflow.clip,
              style: const TextStyle(
                fontSize: FontSize.M,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: theme.primaryColor.withValues(alpha: 0.3),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.post_add_rounded,
                  color: theme.primaryColor,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Post',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: FontSize.M,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 4.0),
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (comment.isEmpty)
                  const Icon(
                    Icons.attach_file_rounded,
                    color: Colors.black87,
                    size: 16.0,
                  ),
                const SizedBox(width: 4.0),
                Flexible(
                  child: Text(
                    comment.isNotEmpty ? comment : 'Attachment',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: FontSize.M,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          ChatTimestampWidget(
            key: UniqueKey(),
            timestamp: time,
            sentByMe: sentByMe,
            chatGroupId: chatGroupId,
            color: const Color(0xFF999999),
            messageId: messageId,
          ),
        ],
      ),
    );
  }
}
