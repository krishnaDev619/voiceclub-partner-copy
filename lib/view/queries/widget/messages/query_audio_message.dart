import 'dart:async';
import 'dart:math';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/data/models/query/query_message_model.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_timestamp_widget.dart';

class QueryAudioMessage extends StatefulWidget {
  final QueryMessageModel message;
  final bool sentByMe;

  const QueryAudioMessage({
    super.key,
    required this.message,
    required this.sentByMe,
  });

  @override
  State<QueryAudioMessage> createState() => _QueryAudioMessageState();
}

class _QueryAudioMessageState extends State<QueryAudioMessage> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;
  int? duration;
  bool isPlayerInitialized = false;
  Worker? callListener;

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

  void registerCallListener() {
    callListener = ever(sl<CallController>().incomingCallPayload, (
      callPayload,
    ) {
      if (callPayload.isNotEmpty) {
        controller.stopPlayer();
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
    final audioUrl = widget.message.attachment ?? '';
    if (audioUrl.isEmpty) return;

    try {
      final audioFile = await DefaultCacheManager().getSingleFile(audioUrl);

      await controller
          .preparePlayer(
            path: audioFile.path,
            shouldExtractWaveform: true,
            noOfSamples: 120,
          )
          .then((_) async {
            duration = (await controller.getDuration()) ~/ 1000;
            setState(() {});
          });
    } catch (_) {}
  }

  Future<void> _togglePlayPause() async {
    if (!isPlayerInitialized) {
      await _preparePlayer();
    }

    if (controller.playerState.isPlaying) {
      await controller.pausePlayer();
    } else {
      await controller.startPlayer();
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    callListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final time = widget.message.createdAt ?? DateTime.now();
    final waveformWidth = MediaQuery.of(context).size.width;
    final primaryColor = const Color(0xFFD1FFCA);

    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: widget.sentByMe ? primaryColor : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(12.0),
          topRight: const Radius.circular(12.0),
          bottomLeft:
              widget.sentByMe
                  ? const Radius.circular(12.0)
                  : const Radius.circular(4.0),
          bottomRight:
              widget.sentByMe
                  ? const Radius.circular(4.0)
                  : const Radius.circular(12.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Play/Pause button
              GestureDetector(
                onTap: _togglePlayPause,
                child: Icon(
                  controller.playerState.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: widget.sentByMe ? Colors.black87 : primaryColor,
                  size: 28.0,
                ),
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child:
                    isPlayerInitialized
                        ? AudioFileWaveforms(
                          key: Key("${widget.message.id}Main"),
                          padding: EdgeInsets.zero,
                          margin: const EdgeInsets.only(left: 3.0),
                          enableSeekGesture: true,
                          playerController: controller,
                          size: Size(MediaQuery.of(context).size.width, 36.0),
                          waveformType: WaveformType.fitWidth,
                          playerWaveStyle: PlayerWaveStyle(
                            spacing: 4.0,
                            scaleFactor: 100.0,
                            waveThickness: 3.0,
                            liveWaveColor:
                                widget.sentByMe
                                    ? Colors.black87
                                    : const Color(0xFF787878),
                            fixedWaveColor:
                                widget.sentByMe
                                    ? Colors.black26
                                    : const Color(0xFFD9D9D9),
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                        )
                        : AudioFileWaveforms(
                          key: Key("${widget.message.id}Placeholder"),
                          padding: EdgeInsets.zero,
                          margin: const EdgeInsets.only(left: 3.0),
                          enableSeekGesture: false,
                          playerController: PlayerController(),
                          waveformData: generateWaveformData(),
                          size: Size(waveformWidth, 36.0),
                          waveformType: WaveformType.fitWidth,
                          playerWaveStyle: PlayerWaveStyle(
                            spacing: 4.0,
                            scaleFactor: 100.0,
                            waveThickness: 3.0,
                            liveWaveColor:
                                widget.sentByMe
                                    ? Colors.black87
                                    : const Color(0xFF787878),
                            fixedWaveColor:
                                widget.sentByMe
                                    ? Colors.black26
                                    : const Color(0xFFD9D9D9),
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                        ),
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  _formatDuration(duration ?? 0),
                  style: TextStyle(
                    fontSize: 11.0,
                    color: isPlayerInitialized ? Colors.black54 : primaryColor,
                  ),
                ),
              ),
              QueryTimestampWidget(timestamp: time, sentByMe: widget.sentByMe),
            ],
          ),
        ],
      ),
    );
  }
}
