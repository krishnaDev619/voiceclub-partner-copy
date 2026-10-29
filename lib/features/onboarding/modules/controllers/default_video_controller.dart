import 'dart:developer';

import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:video_player/video_player.dart';

class DefaultVideoController extends GetxController {
  final String url;
  final isBtnEnabled = false.obs;
  final isVideoPlaying = false.obs;

  DefaultVideoController({required this.url});

  late VideoPlayerController videoPlayerController;

  @override
  void onInit() {
    super.onInit();
    initVideoController();
  }

  @override
  void onClose() {
    videoPlayerController.dispose();
    super.onClose();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  void initVideoController() async {
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        videoPlayerController.play();
        videoPlayerController.setVolume(1.0);
        videoPlayerController.addListener(() {
          if (videoPlayerController.value.isCompleted) {
            isBtnEnabled.value = true;
          }
          isVideoPlaying.value = videoPlayerController.value.isPlaying;
        });
      });
  }

  String getRemainingTime(Duration currentPosition) {
    final duration = videoPlayerController.value.duration;
    final position = currentPosition;
    final remaining = duration - position;

    String remainingTime = formatDuration(remaining);
    return remainingTime;
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void reverseFiveSeconds() {
    var position = videoPlayerController.value.position;
    videoPlayerController.seekTo(position - const Duration(seconds: 5));
  }

  bool get isVideoCompleted => videoPlayerController.value.isCompleted;

  bool get isPaused => !videoPlayerController.value.isPlaying;

  bool get isMuted => videoPlayerController.value.volume == 0.0;

  Future<void> muteOrUnMuteVideo() async {
    if (isMuted) {
      await videoPlayerController.setVolume(1.0);
    } else {
      await videoPlayerController.setVolume(0.0);
    }
  }

  Future<void> playOrPauseVideo(String screenName) async {
    if (isVideoPlaying.value) {
      await videoPlayerController.pause();
      sl<AnalyticsService>().trackEvent(
        "pauseVideo",
        eventProperties: {"screenName": screenName},
      );
    } else {
      await videoPlayerController.play();
      sl<AnalyticsService>().trackEvent(
        "playVideo",
        eventProperties: {"screenName": screenName},
      );
    }
  }

  Future<void> checkAndPauseVideo() async {
    try {
      if (isVideoPlaying.value) {
        await videoPlayerController.pause();
      }
    } catch (e) {
      log("Error pausing video");
    }
  }
}
