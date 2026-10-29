import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/view/chat/widgets/messages/message_reaction_widget.dart';
import 'package:voiceclub_partner/view/chat/widgets/reaction_screen.dart';

class PopupMenuContainer<T> extends StatefulWidget {
  final DisplayChatMessage message;
  final Widget child;
  final bool enabled;
  final VoidCallback? onReport;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;
  final VoidCallback? onReply;
  final Function(String)? onReactionSelected; // Callback for emoji reaction
  final bool sentByMe;
  final String? reaction;

  const PopupMenuContainer({
    super.key,
    required this.child,
    required this.message,
    required this.enabled,
    required this.sentByMe,
    this.onReport,
    this.onDelete,
    this.onCopy,
    this.onReply,
    this.onReactionSelected,
    this.reaction,
  });

  @override
  State<StatefulWidget> createState() => PopupMenuContainerState<T>();
}

class PopupMenuContainerState<T> extends State<PopupMenuContainer<T>> {
  void _showCustomMenu() async {
    HapticFeedback.vibrate();

    Navigator.push<String>(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 100),
        opaque: false,
        pageBuilder:
            (context, _, _) => ReactionScreen(
              message: widget.message,
              onReport: widget.onReport,
              onDelete: widget.onDelete,
              onCopy: widget.onCopy,
              onReply: widget.onReply,
              onReactionSelected: widget.onReactionSelected,
              sentByMe: widget.sentByMe,
              reaction: widget.reaction,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.enabled ? _showCustomMenu : null,
      child: Column(
        crossAxisAlignment:
            widget.sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          widget.child,
          MessageReactionWidget(
            reaction: widget.reaction,
            alignment:
                widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
            onReactionTap: _showCustomMenu,
          ),
        ],
      ),
    );
  }
}
