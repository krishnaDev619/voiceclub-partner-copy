import 'dart:async';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_call_recording.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';

class CallRecordingAudioPlayer extends StatefulWidget {
  final int callId;
  final int groupId;
  final double width;

  const CallRecordingAudioPlayer({
    super.key,
    required this.callId,
    required this.groupId,
    required this.width,
  });

  @override
  State<CallRecordingAudioPlayer> createState() =>
      _CallRecordingAudioPlayerState();
}

class _CallRecordingAudioPlayerState extends State<CallRecordingAudioPlayer> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;
  int? duration;
  bool isPlayerInitialized = false;
  bool isLoading = false;

  final playerWaveStyle = PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Get.theme.primaryColor,
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

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
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
    setState(() {
      isLoading = true;
    });
    try {
      final response = await sl<GetCallRecordingUseCase>().call(
        Params(callId: widget.callId),
      );
      if (response.data?.url?.isNotEmpty ?? false) {
        final audioUrl = response.data?.url ?? "";
        final audioFile = await DefaultCacheManager().getSingleFile(audioUrl);
        await controller
            .preparePlayer(
              path: audioFile.path,
              shouldExtractWaveform: true,
              noOfSamples: playerWaveStyle.getSamplesForWidth(widget.width),
            )
            .then((_) async {
              duration = (await controller.getDuration()) ~/ 1000;
              setState(() {});
            });
        Get.find<ChatMessagesController>(
              tag: widget.groupId.toString(),
            ).playerControllersMap[controller.playerKey] =
            controller;
      }
    } catch (_) {
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

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 64.0, right: 16.0, bottom: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 4.0,
          ),
          fillColor: const Color(0xFFF7F7F7),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 32.0,
              child: Visibility(
                visible: !isLoading,
                replacement: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(
                      color: Get.theme.primaryColor,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
                child: GestureDetector(
                  onTap: () async {
                    if (!isPlayerInitialized) {
                      await _preparePlayer();
                    }
                    Get.find<ChatMessagesController>(
                      tag: widget.groupId.toString(),
                    ).stopAndStartPlayer(
                      playerKey: controller.playerKey,
                      screenName: "CallHistoryScreen",
                      callId: widget.callId,
                      isCallRecording: true,
                    );
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
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child:
                  isPlayerInitialized
                      ? AudioFileWaveforms(
                        key: Key("${widget.callId}CallHistoryMain"),
                        enableSeekGesture: true,
                        playerController: controller,
                        size: Size(widget.width, 28),
                        waveformType: WaveformType.fitWidth,
                        playerWaveStyle: PlayerWaveStyle(
                          spacing: 6.0,
                          scaleFactor: 140.0,
                          waveThickness: 2.5,
                          liveWaveColor: Get.theme.primaryColor,
                          fixedWaveColor: const Color(0xFFD9D9D9),
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        padding: const EdgeInsets.all(0.0),
                        margin: const EdgeInsets.all(0.0),
                      )
                      : AudioFileWaveforms(
                        key: Key("${widget.callId}CallHistoryDuplicate"),
                        waveformData: generateWaveformData(),
                        enableSeekGesture: true,
                        playerController: controller,
                        size: Size(widget.width, 28),
                        waveformType: WaveformType.fitWidth,
                        playerWaveStyle: PlayerWaveStyle(
                          spacing: 6.0,
                          scaleFactor: 140.0,
                          waveThickness: 2.5,
                          liveWaveColor: Get.theme.primaryColor,
                          fixedWaveColor: const Color(0xFFD9D9D9),
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        padding: const EdgeInsets.all(0.0),
                        margin: const EdgeInsets.all(0.0),
                      ),
            ),
            const SizedBox(width: 8.0),
            SizedBox(
              width: 42.0,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Builder(
                  builder: (context) {
                    // Format the time as 0:00
                    final formattedTime = formatTime(duration ?? 0);
                    return Padding(
                      padding: const EdgeInsets.only(left: 4.0, bottom: 1.0),
                      child: Text(
                        formattedTime,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: FontSize.M,
                          color:
                              isPlayerInitialized
                                  ? Colors.grey.shade700
                                  : const Color(0xFFF7F7F7),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
