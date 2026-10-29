import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_audio_button_controller.dart';

class DemoAudioButtonWidget extends StatefulWidget {
  const DemoAudioButtonWidget({super.key});

  @override
  State<DemoAudioButtonWidget> createState() => _DemoAudioButtonWidgetState();
}

class _DemoAudioButtonWidgetState extends State<DemoAudioButtonWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DemoAudioButtonController>();
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(4.0),
        decoration: const BoxDecoration(
          color: Color(0xFFDDB748),
          shape: BoxShape.circle,
        ),
        child: GestureDetector(
          onTap: () async {
            if (controller.playerState.value.isPlaying) {
              controller.playerController.pausePlayer();
            } else {
              controller.playerController.startPlayer();
            }
            setState(() {});
          },
          child: Icon(
            controller.playerState.value.isPlaying
                ? Icons.pause
                : Icons.play_arrow,
            size: 28.0,
            color: Colors.white,
          ),
        ),
      );
    });
  }
}
