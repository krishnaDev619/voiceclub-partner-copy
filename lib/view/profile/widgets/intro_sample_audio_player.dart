import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/intro_audio_showcase_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/view/audios/controllers/intro_audio_controller.dart';
import 'package:voiceclub_partner/view/audios/intro_audio_bottom_sheet.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

final showcaseKey = GlobalKey();

class IntroSampleAudioPlayer extends StatefulWidget {
  final String audioUrl;

  const IntroSampleAudioPlayer({super.key, required this.audioUrl});

  @override
  State<IntroSampleAudioPlayer> createState() => _IntroSampleAudioPlayerState();
}

class _IntroSampleAudioPlayerState extends State<IntroSampleAudioPlayer> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showIntroAudioShowcase();
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
    if (!isPrepared) {
      await controller
          .preparePlayer(path: audioFile.path, shouldExtractWaveform: false)
          .then((_) async {
            if (mounted) {
              final introController = Get.find<IntroAudioController>();
              introController.registerSamplePlayer(controller);
              setState(() {});
            }
          });
    }
  }

  Future<void> _showIntroAudioShowcase() async {
    try {
      final hasShown =
          await IntroAudioShowcaseService.hasIntroAudioShowcaseBeenShown();
      if (!hasShown && mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            try {
              ShowcaseView.getNamed(
                introAudioShowcaseScopeName,
              ).startShowCase([introAudioShowcaseKey]);
            } catch (e) {
              Logger.logMessage("Error starting showcase ${e.toString()}");
            }
          }
        });
      }
    } catch (e) {
      Logger.logMessage("Error in _showIntroAudioShowcase ${e.toString()}");
    }
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    try {
      final introController = Get.find<IntroAudioController>();
      introController.unregisterSamplePlayer(controller);
    } catch (e) {
      // Controller might not exist, ignore
    }
    controller.dispose();
    super.dispose();
  }

  void _play() {
    try {
      if (!hasPlayed) {
        setState(() {
          hasPlayed = true;
        });
      }
      final introController = Get.find<IntroAudioController>();
      introController.stopAndStartSamplePlayer(controller.playerKey);
    } catch (e) {
      Logger.logMessage("Error in _play ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Showcase.withWidget(
      key: introAudioShowcaseKey,
      targetPadding: EdgeInsets.all(8.0),
      targetBorderRadius: BorderRadius.circular(8.0),
      container: IntroAudioShowcaseView(
        title: LocaleKeys.liveListenToSampleAudio.tr,
        angle: -7.0,
      ),
      onTargetClick: () async {
        ShowcaseView.getNamed(introAudioShowcaseScopeName).dismiss();
        await IntroAudioShowcaseService.markIntroAudioShowcaseAsShown();
        _play();
      },
      disposeOnTap: false,
      disableBarrierInteraction: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Builder(
          builder: (context) {
            if (isPrepared) {
              return InkWell(
                onTap: () {
                  _play();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
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
                    const SizedBox(width: 8.0),
                    Shimmer.fromColors(
                      baseColor: Get.theme.primaryColor,
                      highlightColor: Get.theme.primaryColor.withValues(
                        alpha: 0.5,
                      ),
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
                ),
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
      ),
    );
  }
}

class IntroAudioShowcaseView extends StatelessWidget {
  final String title;
  final double angle;

  const IntroAudioShowcaseView({
    super.key,
    required this.title,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width - 80.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: const Text("👆", style: TextStyle(fontSize: 42.0)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: FittedBox(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
