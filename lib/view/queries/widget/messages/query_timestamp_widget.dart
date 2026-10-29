import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class QueryTimestampWidget extends StatelessWidget {
  final DateTime timestamp;
  final bool sentByMe;
  final Color? color;

  const QueryTimestampWidget({
    super.key,
    required this.timestamp,
    required this.sentByMe,
    this.color,
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
            color:
                color ?? (sentByMe ? Colors.black87 : const Color(0xFF999999)),
            textBaseline: TextBaseline.alphabetic,
          ),
        ),
        if (sentByMe)
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Icon(
              Icons.done_all_rounded,
              size: 14.0,
              applyTextScaling: true,
              color: color ?? Colors.black87,
            ),
          ),
      ],
    );
  }
}
