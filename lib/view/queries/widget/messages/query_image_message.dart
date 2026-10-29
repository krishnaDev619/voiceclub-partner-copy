import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:voiceclub_partner/data/models/query/query_message_model.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_full_screen_image.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_timestamp_widget.dart';

class QueryImageMessage extends StatelessWidget {
  final QueryMessageModel message;
  final bool sentByMe;

  const QueryImageMessage({
    super.key,
    required this.message,
    required this.sentByMe,
  });

  @override
  Widget build(BuildContext context) {
    final time = message.createdAt ?? DateTime.now();
    final imageUrl = message.attachment ?? '';
    final size = MediaQuery.of(context).size.width * 0.65;

    return Container(
      width: size,
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
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => QueryFullScreenImage(imageUrl: imageUrl),
                ),
              );
            },
            child: Hero(
              tag: imageUrl,
              child: Container(
                alignment:
                    sentByMe ? Alignment.bottomRight : Alignment.bottomLeft,
                width: size,
                height: size,
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                  image: DecorationImage(
                    image: FastCachedImageProvider(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 2.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: QueryTimestampWidget(
                    timestamp: time,
                    sentByMe: true,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
