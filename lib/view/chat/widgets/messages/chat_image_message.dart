import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_timestamp_widget.dart';
import 'package:voiceclub_partner/view/chat/widgets/full_screen_image.dart';

class ChatImageMessage extends StatelessWidget {
  final String imageUrl;
  final DateTime time;
  final bool sentByMe;
  final ChatTheme theme;
  final int chatGroupId;
  final String documentId;

  const ChatImageMessage({
    super.key,
    required this.imageUrl,
    required this.sentByMe,
    required this.time,
    required this.theme,
    required this.chatGroupId,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.65;
    return Container(
      width: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDE0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              // When the image is tapped, navigate to the full-screen view
              Get.to(() => FullScreenImage(imageUrl: imageUrl));
            },
            child: Hero(
              tag: imageUrl,
              child: Container(
                alignment:
                    sentByMe ? Alignment.bottomLeft : Alignment.bottomRight,
                width: size,
                // Adjust the width and height as needed
                height: size,
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 3.0,
                    color: sentByMe ? theme.primaryColor : Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: FastCachedImageProvider(
                      imageUrl,
                    ), // Load the image from a URL
                    fit: BoxFit.cover,
                  ),
                ),
                child: ChatTimestampWidget(
                  key: UniqueKey(),
                  timestamp: time,
                  sentByMe: sentByMe,
                  chatGroupId: chatGroupId,
                  color: const Color(0xFF999999),
                  messageId: documentId,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
