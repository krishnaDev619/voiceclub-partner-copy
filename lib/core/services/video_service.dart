import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:video_player/video_player.dart';
import 'package:voiceclub_partner/view/home/widgets/video_dialog.dart';

class VideoService {
  static void fetchAndPlayVideo(String url, String title) async {
    try {
      Get.context?.loaderOverlay.show();
      final file = await DefaultCacheManager().getSingleFile(url);
      final path = file.path;
      if (path.isNotEmpty) {
        final videoPlayerController = VideoPlayerController.file(File(path));
        await videoPlayerController.initialize();

        Get.dialog(
          VideoDialog(
            videoPlayerController: videoPlayerController,
            title: title,
          ),
          barrierDismissible: true,
        );
      }
    } catch (_) {
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }
}
