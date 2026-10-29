import 'dart:async';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';

class UploadStoryAudioPlayer extends StatefulWidget {
  final String path;
  final double width, height;
  final String eventType;

  const UploadStoryAudioPlayer({
    super.key,
    required this.width,
    required this.path,
    this.height = 50,
    required this.eventType,
  });

  @override
  State<UploadStoryAudioPlayer> createState() => _UploadStoryAudioPlayerState();
}

class _UploadStoryAudioPlayerState extends State<UploadStoryAudioPlayer> {
  late PlayerController controller;
  late StreamSubscription<PlayerState> playerStateSubscription;
  int? duration;
  Worker? _callListener;

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    spacing: 6,
  );

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    _preparePlayer();
    _registerCallListener();
    playerStateSubscription = controller.onPlayerStateChanged.listen((state) {
      if (state.isInitialised && mounted) {
        controller.setFinishMode(finishMode: FinishMode.pause);
      }
      setState(() {});
    });
  }

  void _registerCallListener() {
    _callListener = ever(sl<CallController>().incomingCallPayload, (
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

  void _preparePlayer() async {
    await controller
        .preparePlayer(
          path: widget.path,
          shouldExtractWaveform: true,
          noOfSamples: playerWaveStyle.getSamplesForWidth(widget.width),
        )
        .then((_) async {
          duration = (await controller.getDuration()) ~/ 1000;
          setState(() {});
        });
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    controller.dispose();
    _callListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!controller.playerState.isStopped)
          GestureDetector(
            onTap: () async {
              controller.playerState.isPlaying
                  ? await controller.pausePlayer()
                  : await controller.startPlayer();
            },
            child: CircleAvatar(
              backgroundColor: Get.theme.primaryColor,
              radius: 14.0,
              child: Icon(
                controller.playerState.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 16.0,
                color: Colors.white,
              ),
            ),
          ),
        const SizedBox(width: 12.0),
        Expanded(
          child: AudioFileWaveforms(
            enableSeekGesture: false,
            playerController: controller,
            size: Size(widget.width, widget.height),
            waveformType: WaveformType.fitWidth,
            playerWaveStyle: const PlayerWaveStyle(
              spacing: 6.0,
              scaleFactor: 100.0,
              waveThickness: 3.0,
              liveWaveColor: Color(0xFF787878),
              fixedWaveColor: Color(0xFFD9D9D9),
            ),
            decoration: const BoxDecoration(color: Colors.transparent),
            padding: const EdgeInsets.all(0.0),
            margin: const EdgeInsets.only(left: 3.0),
          ),
        ),
        const SizedBox(width: 12.0),
        SizedBox(
          width: 32.0,
          child: Builder(
            builder: (context) {
              // Format the time as 0:00
              final formattedTime =
                  '0:${(duration ?? 0).toString().padLeft(2, '0')}';
              return Text(
                formattedTime,
                style: const TextStyle(fontSize: 12.0),
              );
            },
          ),
        ),
      ],
    );
  }
}
