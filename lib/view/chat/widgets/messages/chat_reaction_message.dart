import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_timestamp_widget.dart';

class ChatReactionMessage extends StatelessWidget {
  const ChatReactionMessage({
    super.key,
    required this.supply,
    required this.demand,
    required this.sentByMe,
    required this.reaction,
    required this.time,
    required this.chatGroupId,
    required this.documentId,
  });

  final ChatMember demand, supply;
  final bool sentByMe;
  final String reaction;
  final DateTime time;
  final int chatGroupId;
  final String documentId;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                ? 'You reacted to ${supply.user?.name}\u2019s story'
                : '${demand.user?.name} reacted to your story',
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
          alignment: sentByMe ? Alignment.bottomLeft : Alignment.bottomRight,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AssetConstants.dummyStory),
            ),
          ),
          width: 75.0,
          height: 120.0,
          child: Transform.translate(
            offset:
                sentByMe
                    ? const Offset(-16.0, -12.0)
                    : const Offset(16.0, 12.0),
            child: Text(reaction, style: const TextStyle(fontSize: 32.0)),
          ),
        ),
        ChatTimestampWidget(
          key: UniqueKey(),
          timestamp: time,
          sentByMe: sentByMe,
          chatGroupId: chatGroupId,
          color: const Color(0xFF999999),
          messageId: documentId,
        ),
      ],
    );
  }
}
