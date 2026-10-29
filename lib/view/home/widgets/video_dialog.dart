import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class VideoDialog extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final String title;

  const VideoDialog({
    super.key,
    required this.videoPlayerController,
    required this.title,
  });

  @override
  State<VideoDialog> createState() => _VideoDialogState();
}

class _VideoDialogState extends State<VideoDialog> {
  @override
  void initState() {
    try {
      widget.videoPlayerController.play();
      widget.videoPlayerController.addListener(() {
        if (widget.videoPlayerController.value.isCompleted) {
          stopVideo();
          Get.back();
        }
      });
    } catch (_) {}
    super.initState();
  }

  @override
  void dispose() {
    stopVideo();
    super.dispose();
  }

  void stopVideo() {
    widget.videoPlayerController.pause();
    widget.videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.all(8.0),
      contentPadding: const EdgeInsets.all(0.0),
      iconPadding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Get.theme.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: FontSize.xL,
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            LocaleKeys.homeWatchGuidelines.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: FontSize.xL,
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.all(12.0),
            clipBehavior: Clip.hardEdge,
            height: (MediaQuery.of(context).size.width - 24.0) * (9 / 16),
            width: MediaQuery.of(context).size.width - 24.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: widget.videoPlayerController.value.size.width,
                  height: widget.videoPlayerController.value.size.height,
                  child: VideoPlayer(widget.videoPlayerController),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
