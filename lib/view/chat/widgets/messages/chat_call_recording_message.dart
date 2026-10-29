import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';

class ChatCallRecordingMessage extends StatefulWidget {
  final DateTime time;
  final ChatMember supply;
  final ChatMember demand;
  final CategoryCode categoryCode;
  final int groupId;
  final String callId;
  final ChatTheme theme;
  final DisplayChatMessage message;
  final bool sentByMe;

  const ChatCallRecordingMessage({
    super.key,
    required this.time,
    required this.demand,
    required this.categoryCode,
    required this.supply,
    required this.groupId,
    required this.callId,
    required this.theme,
    required this.message,
    required this.sentByMe,
  });

  @override
  State<ChatCallRecordingMessage> createState() =>
      _ChatCallRecordingMessageState();
}

class _ChatCallRecordingMessageState extends State<ChatCallRecordingMessage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6.0),
      margin: EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: MediaQuery.of(context).size.width * 0.25,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.call_rounded, color: Colors.green, size: 18.0),
          Flexible(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Call with ${widget.demand.user?.name ?? 'User'}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(textBaseline: TextBaseline.alphabetic),
              ),
            ),
          ),
          Text(
            DateFormat.Hm().format(widget.time),
            style: const TextStyle(
              height: 1.5,
              fontSize: FontSize.S,
              color: Color(0xFF999999),
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
        ],
      ),
    );
  }
}
