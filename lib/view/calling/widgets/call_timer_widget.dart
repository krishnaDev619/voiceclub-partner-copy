import 'package:flutter/material.dart';
import 'package:voiceclub_partner/data/models/calling/call_model.dart';

class CallTimerWidget extends StatelessWidget {
  final bool isAccepted;
  final int callDurationSeconds;
  final bool remoteUserMute;
  final CallModel? callModel;
  final bool isNewUser;

  const CallTimerWidget({
    super.key,
    required this.isAccepted,
    required this.callDurationSeconds,
    required this.remoteUserMute,
    required this.callModel,
    this.isNewUser = false,
  });

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isAccepted,
      replacement: Text(
        "Incoming call",
        style: TextStyle(color: isNewUser ? Colors.white : Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatTime(callDurationSeconds),
              style: TextStyle(color: isNewUser ? Colors.white : Colors.black),
            ),
            // Visibility(
            //   visible: callModel?.showBehaviourProgress ?? false,
            //   child: FriendshipProgressBar(
            //     seconds: callDurationSeconds,
            //     callModel: callModel,
            //     width: Get.width - 32.0,
            //   ),
            // ),
            Visibility(
              visible: remoteUserMute,
              child: Text(
                "Muted",
                style: TextStyle(
                  color: isNewUser ? Colors.white : Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
