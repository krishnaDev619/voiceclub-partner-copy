import 'dart:async';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/managers_feedback_controller.dart';

class ManagersFeedbackAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final String feedbackDate;
  final double width;
  final double height;
  final double? containerWidth;
  final Color? containerBackgroundColor;
  final BoxBorder? containerBorder;
  final Color? fixedWaveColor;
  final Color? liveWaveColor;
  final Color? playButtonColor;
  final VoidCallback? onCompletion;
  final bool showText;

  const ManagersFeedbackAudioPlayer({
    super.key,
    required this.audioUrl,
    required this.feedbackDate,
    required this.width,
    this.height = 36,
    this.containerWidth,
    this.containerBackgroundColor,
    this.containerBorder,
    this.fixedWaveColor,
    this.liveWaveColor,
    this.playButtonColor,
    this.onCompletion,
    this.showText = true,
  });

  @override
  State<ManagersFeedbackAudioPlayer> createState() =>
      _ManagersFeedbackAudioPlayerState();
}

class _ManagersFeedbackAudioPlayerState
    extends State<ManagersFeedbackAudioPlayer> {
  late PlayerController controller;
  late PlayerController fakeAudioController;
  late StreamSubscription<PlayerState> playerStateSubscription;
  late StreamSubscription<void> completionSubscription;
  int? duration;
  bool isPlayerInitialized = false;
  bool isLoading = false;
  late ManagersFeedbackController managersFeedbackController;
  late double waveformWidth;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.blue,
    liveWaveColor: Colors.red,
    spacing: 6,
  );

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    fakeAudioController = PlayerController();
    managersFeedbackController = Get.find<ManagersFeedbackController>();
    // Calculate waveform width: screen width - container padding (8*2) - play button (20) - spacer (8) - some margin
    waveformWidth = Get.width - 16.0 - 20.0 - 8.0 - 16.0;
    playerStateSubscription = controller.onPlayerStateChanged.listen((state) {
      if (mounted) {
        if (state.isInitialised) {
          controller.setFinishMode(finishMode: FinishMode.pause);
          if (!isPlayerInitialized) {
            isPlayerInitialized = true;
          }
        }
        setState(() {});
      }
    });
    completionSubscription = controller.onCompletion.listen((_) {
      if (mounted) {
        widget.onCompletion?.call();
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  List<double> generateWaveformData({
    int length = 100,
    double amplitude = 0.2,
  }) {
    Random random = Random();
    List<double> waveformData = [];

    for (int i = 0; i < length; i++) {
      double value = random.nextDouble() * 0.4;
      waveformData.add((value / 5));
    }

    return waveformData;
  }

  Future<void> _preparePlayer() async {
    setState(() {
      isLoading = true;
    });
    try {
      final audioFile = await DefaultCacheManager().getSingleFile(
        widget.audioUrl,
      );
      await controller
          .preparePlayer(
            path: audioFile.path,
            shouldExtractWaveform: true,
            noOfSamples: playerWaveStyle.getSamplesForWidth(waveformWidth),
          )
          .then((_) async {
            duration = (await controller.getDuration()) ~/ 1000;
            setState(() {});
          });
      // Register the controller with the managers feedback controller
      managersFeedbackController.playerControllersMap[controller.playerKey] =
          controller;
      sl<AnalyticsService>().trackEvent(
        "feedbackAudioPlayButton",
        eventProperties: {
          "feedbackUrl": widget.audioUrl,
          "feedbackDate": widget.feedbackDate,
        },
      );
    } catch (_) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Remove controller from the map before disposing
    managersFeedbackController.playerControllersMap.remove(
      controller.playerKey,
    );
    // If this was the current player, clear the current player path
    if (managersFeedbackController.currentPlayerPath.value ==
        controller.playerKey) {
      managersFeedbackController.currentPlayerPath.value = "";
    }
    playerStateSubscription.cancel();
    completionSubscription.cancel();
    controller.dispose();
    fakeAudioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playButtonColor = widget.playButtonColor ?? Color(0xFFEE6464);
    final liveWaveColor = widget.liveWaveColor ?? Colors.red;
    final fixedWaveColor =
        widget.fixedWaveColor ?? Color(0xFFEE6464).withAlpha(80);

    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Get.width,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20.0,
                      child: Visibility(
                        visible: !isLoading,
                        replacement: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: SizedBox(
                            height: 14.0,
                            width: 14.0,
                            child: CircularProgressIndicator(
                              color: playButtonColor,
                              strokeWidth: 1.5,
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            if (!isPlayerInitialized) {
                              await _preparePlayer();
                              managersFeedbackController.stopAndStartPlayer(
                                playerKey: controller.playerKey,
                              );
                            } else {
                              managersFeedbackController.stopAndStartPlayer(
                                playerKey: controller.playerKey,
                              );
                            }
                          },
                          child: Icon(
                            controller.playerState.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: playButtonColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child:
                          isPlayerInitialized
                              ? AudioFileWaveforms(
                                key: Key("${widget.audioUrl}Main"),
                                padding: const EdgeInsets.all(0.0),
                                margin: const EdgeInsets.only(left: 3.0),
                                enableSeekGesture: true,
                                playerController: controller,
                                size: Size(waveformWidth, widget.height),
                                waveformType: WaveformType.fitWidth,
                                playerWaveStyle: PlayerWaveStyle(
                                  spacing: 5.0,
                                  scaleFactor: 120.0,
                                  waveThickness: 2.0,
                                  liveWaveColor: liveWaveColor,
                                  fixedWaveColor: fixedWaveColor,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              )
                              : AudioFileWaveforms(
                                key: Key("${widget.audioUrl}Duplicate"),
                                padding: const EdgeInsets.all(0.0),
                                margin: const EdgeInsets.only(left: 3.0),
                                enableSeekGesture: false,
                                playerController: fakeAudioController,
                                waveformData: generateWaveformData(),
                                size: Size(waveformWidth, widget.height),
                                waveformType: WaveformType.fitWidth,
                                playerWaveStyle: PlayerWaveStyle(
                                  spacing: 5.0,
                                  scaleFactor: 120.0,
                                  waveThickness: 2.0,
                                  liveWaveColor: liveWaveColor,
                                  fixedWaveColor: fixedWaveColor,
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
