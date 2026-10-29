import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class DemoChatTimestampWidget extends StatelessWidget {
  final DateTime timestamp;
  final bool sentByMe;
  final int chatGroupId;
  final Color color;
  final String messageId;

  const DemoChatTimestampWidget({
    super.key,
    required this.timestamp,
    required this.sentByMe,
    required this.chatGroupId,
    required this.messageId,
    this.color = const Color(0xFFF0F0F0),
  });

  @override
  Widget build(BuildContext context) {
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
      ],
    );
  }
}
