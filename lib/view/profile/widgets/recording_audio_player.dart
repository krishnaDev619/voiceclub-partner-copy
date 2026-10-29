import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/view/profile/widgets/upload_audio_bottom_sheet/upload_audio_bottom_sheet_controller.dart';

class RecordingAudioPlayer extends StatefulWidget {
  final String audioUrl;
  final double width;
  final String pendingAudioUrl;
  final RecordingAudioStatus? status;

  const RecordingAudioPlayer({
    super.key,
    required this.width,
    required this.audioUrl,
    required this.pendingAudioUrl,
    required this.status,
  });

  @override
  State<RecordingAudioPlayer> createState() => _RecordingAudioPlayerState();
}

class _RecordingAudioPlayerState extends State<RecordingAudioPlayer> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;
  Future<void>? prepareFuture;
  bool hasPlayed = false;

  final playerWaveStyle = PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Get.theme.primaryColor,
    spacing: 6,
  );

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    prepareFuture = _preparePlayer();
    playerStateSubscription = controller.onPlayerStateChanged.listen((state) {
      if (state.isInitialised && mounted) {
        controller.setFinishMode(finishMode: FinishMode.pause);
      }
      setState(() {});
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> _preparePlayer() async {
    var audioUrl = widget.audioUrl;
    if (widget.status == RecordingAudioStatus.Pending &&
        widget.pendingAudioUrl.isNotEmpty) {
      audioUrl = widget.pendingAudioUrl;
    }
    final audioFile = await DefaultCacheManager().getSingleFile(audioUrl);
    await controller
        .preparePlayer(
          path: audioFile.path,
          shouldExtractWaveform: true,
          noOfSamples: playerWaveStyle.getSamplesForWidth(widget.width),
        )
        .then((_) async {
          setState(() {});
        });
    Get.find<UploadAudioBottomSheetController>().playerControllersMap[controller
            .playerKey] =
        controller;
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: prepareFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator with a colored background
          return const Center(
            child: SizedBox(
              height: 12.0,
              width: 12.0,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: Colors.grey,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const SizedBox.shrink();
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!controller.playerState.isStopped)
                GestureDetector(
                  onTap: () async {
                    if (!hasPlayed) {
                      setState(() {
                        hasPlayed = true;
                      });
                    }
                    Get.find<UploadAudioBottomSheetController>()
                        .stopAndStartPlayer(controller.playerKey);
                  },
                  child: CircleAvatar(
                    backgroundColor: Get.theme.primaryColor,
                    radius: 14.0,
                    child: Icon(
                      controller.playerState.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(width: 8.0),
              Expanded(
                child: AudioFileWaveforms(
                  enableSeekGesture: true,
                  playerController: controller,
                  size: Size(widget.width, 42),
                  waveformType: WaveformType.fitWidth,
                  playerWaveStyle: PlayerWaveStyle(
                    spacing: 6.0,
                    scaleFactor: 180.0,
                    waveThickness: 3.0,
                    liveWaveColor: Get.theme.primaryColor,
                    fixedWaveColor: const Color(0xFFD9D9D9),
                  ),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  padding: const EdgeInsets.all(0.0),
                  margin: const EdgeInsets.all(0.0),
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                '0:${(controller.maxDuration ~/ 1000).toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          );
        }
      },
    );
  }
}
