import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/modules/controller/calls/outgoing_call_controller.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_end_button.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_mute_button.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_report_button.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_speaker_button.dart';

class OutgoingCallFunctionsWidget extends StatelessWidget {
  const OutgoingCallFunctionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final outgoingCallController = Get.find<OutgoingCallController>();
    const fixedWidth = 64.0;
    final dynamicWidth = (Get.width - 80.0) / 4;
    final size = fixedWidth > dynamicWidth ? dynamicWidth : fixedWidth;
    return Obx(() {
      bool isAccepted = outgoingCallController.isAccepted.value;
      return Container(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 48.0),
        decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CallMuteButton(
              size: size,
              muteSeconds: 1,
              isMuted: outgoingCallController.isMuted.value,
              onTap: outgoingCallController.enableLocalAudio,
            ),
            CallReportButton(
              size: size,
              onReport: (blockMessage) {
                if (isAccepted) {
                  outgoingCallController.trackCallEvent("callAlertSuccess");
                  outgoingCallController.sendUserMessage(message: blockMessage);
                }
              },
            ),
            CallSpeakerButton(
              size: size,
              onTap: outgoingCallController.switchAudioRoute,
              isSpeaker: outgoingCallController.isSpeaker.value,
            ),
            CallEndButton(
              size: size,
              onEndFail: () {
                outgoingCallController.trackCallEvent(
                  "callDeclineOption",
                  additionalProperties: {"option": "NO"},
                );
                Get.back();
              },
              onEndSuccess: () {
                outgoingCallController.trackCallEvent(
                  "callDeclineOption",
                  additionalProperties: {"option": "YES"},
                );
                Get.back();
                outgoingCallController.leave(isMe: true);
              },
            ),
          ],
        ),
      );
    });
  }
}
