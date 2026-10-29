import 'dart:async';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';

class PostAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;

  const PostAudioPlayer({
    super.key,
    required this.audioUrl,
    required this.width,
    required this.height,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  State<PostAudioPlayer> createState() => _PostAudioPlayerState();
}

class _PostAudioPlayerState extends State<PostAudioPlayer> {
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
      if (state == PlayerState.initialized && mounted) {
        controller.setFinishMode(finishMode: FinishMode.pause);
        isPlayerInitialized = true;
      }
      setState(() {});
    });
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
    try {
      final audioFile = await DefaultCacheManager().getSingleFile(
        widget.audioUrl,
      );
      await controller
          .preparePlayer(
            path: audioFile.path,
            shouldExtractWaveform: true,
            noOfSamples: playerWaveStyle.getSamplesForWidth(widget.width),
          )
          .then((_) async {
            duration = (await controller.getDuration()) ~/ 1000;
            if (mounted) {
              setState(() {});
            }
            if (mounted) {
              Get.find<ExploreController>().addPlayerController(
                playerKey: controller.playerKey,
                playerController: controller,
              );
            }
          });
    } catch (_) {}
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayerWidth = widget.width - 51.0;
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
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
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(
                controller.playerState.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                color: widget.textColor,
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
                      size: Size(audioPlayerWidth, widget.height),
                      waveformType: WaveformType.fitWidth,
                      playerWaveStyle: PlayerWaveStyle(
                        spacing: 5.0,
                        scaleFactor: 120.0,
                        waveThickness: 2.0,
                        liveWaveColor: Colors.white,
                        fixedWaveColor: Colors.white.withValues(alpha: 0.5),
                      ),
                    )
                    : AudioFileWaveforms(
                      key: Key("${widget.audioUrl}Duplicate"),
                      padding: const EdgeInsets.all(0.0),
                      margin: const EdgeInsets.only(left: 3.0),
                      enableSeekGesture: false,
                      playerController: PlayerController(),
                      waveformData: generateWaveformData(),
                      size: Size(audioPlayerWidth, widget.height),
                      waveformType: WaveformType.fitWidth,
                      playerWaveStyle: PlayerWaveStyle(
                        spacing: 5.0,
                        scaleFactor: 120.0,
                        waveThickness: 2.0,
                        liveWaveColor: Colors.white,
                        fixedWaveColor: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
