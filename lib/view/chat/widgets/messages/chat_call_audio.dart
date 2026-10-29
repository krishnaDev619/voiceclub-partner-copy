import 'dart:async';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_call_recording.dart';
import 'package:voiceclub_partner/modules/controller/chat_messages_controller.dart';

class ChatCallAudio extends StatefulWidget {
  final DateTime time;
  final double width, height;
  final bool sentByMe;
  final int groupId;
  final String callId;
  final ChatTheme theme;

  const ChatCallAudio({
    super.key,
    required this.width,
    required this.time,
    required this.sentByMe,
    required this.groupId,
    required this.callId,
    this.height = 36,
    required this.theme,
  });

  @override
  State<ChatCallAudio> createState() => _ChatCallAudioState();
}

class _ChatCallAudioState extends State<ChatCallAudio> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;
  int? duration;
  bool isPlayerInitialized = false;
  bool isLoading = false;

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

  @override
  setState(fn) {
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
        Params(callId: int.tryParse(widget.callId) ?? 0),
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
    if (seconds > 0) {
      final minutes = (seconds ~/ 60);
      final remainingSeconds = seconds % 60;

      final formattedMinutes = minutes.toString().padLeft(2, '0');
      final formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

      return '$formattedMinutes:$formattedSeconds';
    } else {
      return 'Call Recording';
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
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDE0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.65,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color:
                  (widget.sentByMe
                      ? const Color(0xFFFF8787).withValues(alpha: 0.75)
                      : const Color(0xFFF7F7F7)),
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
                              color: widget.theme.primaryColor,
                              strokeWidth: 1.5,
                            ),
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            if (!isPlayerInitialized) {
                              await _preparePlayer();
                            }
                            if (Get.isRegistered<ChatMessagesController>(
                              tag: widget.groupId.toString(),
                            )) {
                              Get.find<ChatMessagesController>(
                                tag: widget.groupId.toString(),
                              ).stopAndStartPlayer(
                                screenName: "ChatScreen",
                                playerKey: controller.playerKey,
                                isCallRecording: true,
                                callId: int.tryParse(widget.callId) ?? 0,
                              );
                            }
                          },
                          child: Icon(
                            controller.playerState.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color:
                                widget.sentByMe
                                    ? Colors.white
                                    : widget.theme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child:
                          isPlayerInitialized
                              ? AudioFileWaveforms(
                                key: Key("${widget.time}CallMain"),
                                padding: const EdgeInsets.all(0.0),
                                margin: const EdgeInsets.only(left: 3.0),
                                enableSeekGesture: false,
                                playerController: controller,
                                size: Size(widget.width, widget.height),
                                waveformType: WaveformType.fitWidth,
                                playerWaveStyle: PlayerWaveStyle(
                                  spacing: 5.0,
                                  scaleFactor: 120.0,
                                  waveThickness: 2.0,
                                  liveWaveColor:
                                      widget.sentByMe
                                          ? Colors.white
                                          : const Color(0xFF787878),
                                  fixedWaveColor:
                                      widget.sentByMe
                                          ? Colors.white54
                                          : const Color(0xFFD9D9D9),
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              )
                              : AudioFileWaveforms(
                                key: Key("${widget.time}CallDuplicate"),
                                padding: const EdgeInsets.all(0.0),
                                margin: const EdgeInsets.only(left: 3.0),
                                enableSeekGesture: false,
                                playerController: PlayerController(),
                                waveformData: generateWaveformData(),
                                size: Size(widget.width, widget.height),
                                waveformType: WaveformType.fitWidth,
                                playerWaveStyle: PlayerWaveStyle(
                                  spacing: 5.0,
                                  scaleFactor: 120.0,
                                  waveThickness: 2.0,
                                  liveWaveColor:
                                      widget.sentByMe
                                          ? Colors.white
                                          : const Color(0xFF787878),
                                  fixedWaveColor:
                                      widget.sentByMe
                                          ? Colors.white54
                                          : const Color(0xFFD9D9D9),
                                ),
                                decoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                              ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) {
                        // Format the time as 0:00
                        final formattedTime = formatTime(duration ?? 0);
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 4.0,
                            bottom: 1.0,
                          ),
                          child: Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: FontSize.M,
                              color:
                                  isPlayerInitialized
                                      ? Colors.black
                                      : Colors.black38,
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      DateFormat.Hm().format(widget.time),
                      style: TextStyle(
                        height: 0.8,
                        fontSize:
                            isPlayerInitialized ? FontSize.S : FontSize.xS,
                        color:
                            widget.sentByMe
                                ? const Color(0xFFF0F0F0)
                                : const Color(0xFF999999),
                        textBaseline: TextBaseline.alphabetic,
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
