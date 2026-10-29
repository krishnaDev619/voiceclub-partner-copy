import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';

class ChatViewedCallMessage extends StatelessWidget {
  const ChatViewedCallMessage({
    super.key,
    required this.demand,
    required this.supply,
    required this.sentByMe,
    required this.time,
  });

  final DateTime time;
  final ChatMember demand, supply;
  final bool sentByMe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6.0),
      margin: EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: MediaQuery.of(context).size.width * 0.2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_missed_rounded,
              color: Colors.amber,
              size: 18.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                "Missed Call (no penalty)",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(textBaseline: TextBaseline.alphabetic),
              ),
            ),
            Text(
              DateFormat.Hm().format(time),
              style: const TextStyle(
                height: 1.5,
                fontSize: FontSize.S,
                color: Color(0xFF999999),
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
