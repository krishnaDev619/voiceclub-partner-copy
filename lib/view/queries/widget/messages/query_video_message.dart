import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/data/models/query/query_message_model.dart';
import 'package:voiceclub_partner/view/learning/video_player_screen.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_timestamp_widget.dart';

class QueryVideoMessage extends StatelessWidget {
  final QueryMessageModel message;
  final bool sentByMe;

  const QueryVideoMessage({
    super.key,
    required this.message,
    required this.sentByMe,
  });

  @override
  Widget build(BuildContext context) {
    final time = message.createdAt ?? DateTime.now();
    final videoUrl = message.attachment ?? '';
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
                  ? const Radius.circular(4.0)
                  : const Radius.circular(12.0),
          bottomRight:
              sentByMe
                  ? const Radius.circular(12.0)
                  : const Radius.circular(4.0),
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
              if (videoUrl.isNotEmpty) {
                Get.to(
                  () => VideoPlayerScreen(
                    videoUrl: videoUrl,
                    allowFullScreen: true,
                  ),
                );
              }
            },
            child: Container(
              alignment:
                  sentByMe ? Alignment.bottomRight : Alignment.bottomLeft,
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                  bottomLeft:
                      sentByMe
                          ? const Radius.circular(4.0)
                          : const Radius.circular(12.0),
                  bottomRight:
                      sentByMe
                          ? const Radius.circular(12.0)
                          : const Radius.circular(4.0),
                ),
                image: const DecorationImage(
                  image: AssetImage(AssetConstants.videoThumbnail),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black38,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // Play button overlay
                  Center(
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      child: const Icon(
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 50.0,
                      ),
                    ),
                  ),
                  // Timestamp
                  Positioned(
                    bottom: 8.0,
                    left: sentByMe ? null : 8.0,
                    right: sentByMe ? 8.0 : null,
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
                        sentByMe: sentByMe,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
