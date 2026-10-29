import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final double width;
  final File? attachment;

  const AudioPlayerWidget({
    super.key,
    required this.audioUrl,
    this.width = 0,
    this.attachment,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;
  int? duration;
  bool isPlayerInitialized = false;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    spacing: 6,
  );

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    playerStateSubscription = controller.onPlayerStateChanged.listen((state) {
      if (state.isInitialised && mounted) {
        controller.setFinishMode(finishMode: FinishMode.pause);
        isPlayerInitialized = true;
      }
      setState(() {});
    });
  }

  List<double> generateWaveformData({
    int length = 100, // Length of the waveform data
    double amplitude = 0.2, // Amplitude of the waveform
  }) {
    Random random = Random();
    List<double> waveformData = [];

    for (int i = 0; i < length; i++) {
      // Generate random amplitude values between 0.3 and 0.7
      double value =
          random.nextDouble() *
          0.4; // Scaling to fit -amplitude to amplitude range

      waveformData.add((value / 5));
    }

    return waveformData;
  }

  Future<void> _preparePlayer() async {
    File? audioFile;
    if (widget.audioUrl.isNotEmpty) {
      audioFile = await DefaultCacheManager().getSingleFile(widget.audioUrl);
    } else if (widget.attachment != null) {
      audioFile = widget.attachment;
    }
    await controller
        .preparePlayer(
          path: audioFile?.path ?? '',
          shouldExtractWaveform: true,
          noOfSamples: playerWaveStyle.getSamplesForWidth(widget.width),
        )
        .then((_) async {
          duration = (await controller.getDuration()) ~/ 1000;
          if (mounted) {
            setState(() {});
            Get.find<ExploreController>().addPlayerController(
              playerKey: controller.playerKey,
              playerController: controller,
            );
          }
        });
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDE0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (!isPlayerInitialized) {
                          await _preparePlayer();
                        }
                        Get.find<ExploreController>().stopAndStartPlayer(
                          controller.playerKey,
                        );
                      },
                      child: Icon(
                        controller.playerState.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Get.theme.primaryColor,
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
                                size: Size(widget.width, 50),
                                waveformType: WaveformType.fitWidth,
                                playerWaveStyle: const PlayerWaveStyle(
                                  spacing: 5.0,
                                  scaleFactor: 120.0,
                                  waveThickness: 2.0,
                                  liveWaveColor: Color(0xFF787878),
                                  fixedWaveColor: Color(0xFFD9D9D9),
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
                                playerController: PlayerController(),
                                waveformData: generateWaveformData(),
                                size: Size(widget.width, 50),
                                waveformType: WaveformType.fitWidth,
                                playerWaveStyle: const PlayerWaveStyle(
                                  spacing: 5.0,
                                  scaleFactor: 120.0,
                                  waveThickness: 2.0,
                                  liveWaveColor: Color(0xFF787878),
                                  fixedWaveColor: Color(0xFFD9D9D9),
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              ),
                    ),
                  ],
                ),
                // if (isPlayerInitialized)
                //   Builder(
                //     builder: (context) {
                //       // Format the time as 0:00
                //       final formattedTime =
                //           '0:${(duration ?? 0).toString().padLeft(2, '0')}';
                //       return Padding(
                //         padding: const EdgeInsets.only(left: 4.0, bottom: 1.0),
                //         child: Text(
                //           formattedTime,
                //           style: TextStyle(
                //             fontSize: FontSize.M,
                //             color: isPlayerInitialized
                //                 ? Colors.black
                //                 : Colors.black,
                //           ),
                //         ),
                //       );
                //     },
                //   ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
