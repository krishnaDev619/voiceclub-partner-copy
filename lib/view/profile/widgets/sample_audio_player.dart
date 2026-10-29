import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/profile/widgets/upload_audio_bottom_sheet/upload_audio_bottom_sheet_controller.dart';

class SampleAudioPlayer extends StatefulWidget {
  final String audioUrl;

  const SampleAudioPlayer({super.key, required this.audioUrl});

  @override
  State<SampleAudioPlayer> createState() => _SampleAudioPlayerState();
}

class _SampleAudioPlayerState extends State<SampleAudioPlayer> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;
  bool hasPlayed = false;
  bool isPrepared = false;

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    _preparePlayer();
    playerStateSubscription = controller.onPlayerStateChanged.listen((state) {
      if (state.isInitialised && mounted) {
        controller.setFinishMode(finishMode: FinishMode.pause);
        isPrepared = true;
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
    final audioFile = await DefaultCacheManager().getSingleFile(
      widget.audioUrl,
    );
    await controller
        .preparePlayer(path: audioFile.path, shouldExtractWaveform: false)
        .then((_) async {
          if (mounted) {
            Get.find<UploadAudioBottomSheetController>()
                    .playerControllersMap[controller.playerKey] =
                controller;
            setState(() {});
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
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Builder(
        builder: (context) {
          if (isPrepared) {
            // Show loading indicator with a colored background
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Get.theme.primaryColor,
                        highlightColor: Get.theme.primaryColor.withValues(
                          alpha: 0.5,
                        ),
                        child: CircleAvatar(
                          radius: 12.0,
                          backgroundColor: Get.theme.primaryColor,
                        ),
                      ),
                      Icon(
                        controller.playerState.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 20.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8.0),
                Shimmer.fromColors(
                  baseColor: Get.theme.primaryColor,
                  highlightColor: Get.theme.primaryColor.withValues(alpha: 0.5),
                  child: Text(
                    LocaleKeys.playSampleAudio.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.L,
                      color: Get.theme.primaryColor,
                      decoration: TextDecoration.underline,
                      decorationColor: Get.theme.primaryColor,
                      decorationThickness: 2.0,
                    ),
                  ),
                ),
              ],
            );
          } else {
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
          }
        },
      ),
    );
  }
}
