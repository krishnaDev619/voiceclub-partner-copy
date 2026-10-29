import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';

class DemoAudioButtonController extends GetxController {
  final playerController = PlayerController();
  StreamSubscription<PlayerState>? playerStream;
  final playerState = PlayerState.stopped.obs;

  @override
  void onInit() {
    super.onInit();
    playerStream = playerController.onPlayerStateChanged.listen((state) {
      playerState.value = state;
      if (state.isInitialised) {
        playerController.setFinishMode(finishMode: FinishMode.pause);
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    playerStream?.cancel();
    playerController.dispose();
  }

  void playNewAudio(String audioUrl) {
    playerController.stopPlayer();
    _preparePlayer(audioUrl);
  }

  Future<void> _preparePlayer(String audioUrl) async {
    final audioFile = await DefaultCacheManager().getSingleFile(audioUrl);
    await playerController
        .preparePlayer(path: audioFile.path, shouldExtractWaveform: false)
        .then((_) async {
          playerController.startPlayer();
        });
  }
}
