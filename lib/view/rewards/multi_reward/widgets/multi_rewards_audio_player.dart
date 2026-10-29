import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/rewards/rewards.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';

class MultiRewardsAudioPlayer extends StatefulWidget {
  final double width;
  final Rewards reward;

  const MultiRewardsAudioPlayer({
    super.key,
    required this.width,
    required this.reward,
  });

  @override
  State<MultiRewardsAudioPlayer> createState() =>
      _MultiRewardsAudioPlayerState();
}

class _MultiRewardsAudioPlayerState extends State<MultiRewardsAudioPlayer> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;
  bool isPlayerInitialized = false;
  bool isLoading = false;
  String? extractedAudioUrl;

  final playerWaveStyle = PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Get.theme.primaryColor,
    spacing: 6,
  );

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    _preparePlayer();
    playerStateSubscription = controller.onPlayerStateChanged.listen((state) {
      if (state.isInitialised && mounted) {
        isPlayerInitialized = true;
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

  Future<void> _extractAudioUrl() async {
    final language =
        Get.find<UserController>().userDetails.value.primaryLanguage;

    if (widget.reward.rewardAudios != null &&
        widget.reward.rewardAudios!.isNotEmpty) {
      if (language?.toLowerCase() == 'tamil') {
        // Pick Tamil audio if user's language is Tamil
        final tamilAudio =
            widget.reward.rewardAudios!
                .where((element) => element.language?.toLowerCase() == 'tamil')
                .firstOrNull;
        extractedAudioUrl = tamilAudio?.audioUrl;
      } else {
        // Pick non-Tamil audio in any other case
        final nonTamilAudio =
            widget.reward.rewardAudios!
                .where((element) => element.language?.toLowerCase() != 'tamil')
                .firstOrNull;
        extractedAudioUrl = nonTamilAudio?.audioUrl;
      }
    }
  }

  Future<void> _preparePlayer() async {
    setState(() {
      isLoading = true;
    });
    try {
      // First extract the appropriate audio URL based on user's language
      await _extractAudioUrl();

      if (extractedAudioUrl != null && extractedAudioUrl!.isNotEmpty) {
        final audioFile = await DefaultCacheManager().getSingleFile(
          extractedAudioUrl!,
        );
        await controller.preparePlayer(
          path: audioFile.path,
          shouldExtractWaveform: true,
          noOfSamples: playerWaveStyle.getSamplesForWidth(150),
        );
      } else {
        Logger.logMessage("No audio URL found for multi rewards header view");
      }
    } catch (e) {
      Logger.logMessage(
        "Error initializing audio player in multi rewards header view ${e.toString()}",
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60);
    final remainingSeconds = seconds % 60;

    final formattedMinutes = minutes.toString().padLeft(2, '0');
    final formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

    return '$formattedMinutes:$formattedSeconds';
  }

  Future<void> checkAndStartPlayer() async {
    if (controller.playerState.isPlaying) {
      controller.pausePlayer();
    } else {
      controller.startPlayer();
    }
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.reward.rewardAudios?.isNotEmpty == true,
      replacement: const SizedBox(height: 34.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            child: Visibility(
              visible: !isLoading,
              replacement: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(
                    color: (widget.reward.colorCode ?? "").toColor(),
                    strokeWidth: 1.5,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  checkAndStartPlayer();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (widget.reward.colorCodeDark ?? "").toColor(),
                  ),
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    controller.playerState.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 26.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: AudioFileWaveforms(
              enableSeekGesture: true,
              playerController: controller,
              size: Size(widget.width, 34),
              waveformType: WaveformType.fitWidth,
              playerWaveStyle: PlayerWaveStyle(
                spacing: 6.0,
                scaleFactor: 140.0,
                waveThickness: 2.5,
                liveWaveColor:
                    (widget.reward.colorCodeSecondary ?? "").toColor(),
                fixedWaveColor: (widget.reward.colorCodeDark ?? "").toColor(),
              ),
              waveformData: controller.waveformExtraction.waveformData,
              decoration: const BoxDecoration(color: Colors.transparent),
              padding: const EdgeInsets.all(0.0),
              margin: const EdgeInsets.all(0.0),
            ),
          ),
        ],
      ),
    );
  }
}
