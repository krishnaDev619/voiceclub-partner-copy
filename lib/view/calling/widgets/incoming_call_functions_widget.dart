import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/modules/controller/calls/incoming_call_controller.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_end_button.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_mute_button.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_report_button.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_speaker_button.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_to_chat_button.dart';
import 'package:voiceclub_partner/view/chat/chat_overview_screen.dart';

class IncomingCallFunctionsWidget extends StatelessWidget {
  const IncomingCallFunctionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final incomingCallController = Get.find<IncomingCallController>();
    const fixedWidth = 64.0;
    final dynamicWidth = (Get.width - 80.0) / 4;
    final size = fixedWidth > dynamicWidth ? dynamicWidth : fixedWidth;
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CallToChatButton(
            onTap: () {
              incomingCallController.trackCallEvent("callToChatPartner");
              Get.to(() => const ChatOverviewScreen());
            },
          ),
          Container(
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
                  muteSeconds: incomingCallController.muteSeconds.value,
                  isMuted: incomingCallController.isMuted.value,
                  onTap: incomingCallController.enableLocalAudio,
                ),
                CallReportButton(
                  size: size,
                  onReport: (blockMessage) {
                    incomingCallController.trackCallEvent("callAlertSuccess");
                    incomingCallController.sendUserMessage(
                      encodedMessage: blockMessage,
                    );
                  },
                ),
                CallSpeakerButton(
                  size: size,
                  onTap: incomingCallController.switchAudioRoute,
                  isSpeaker: incomingCallController.isSpeaker.value,
                ),
                CallEndButton(
                  size: size,
                  onEndFail: () {
                    incomingCallController.trackCallEvent(
                      "callDeclineOption",
                      additionalProperties: {"option": "NO"},
                    );
                    Get.back();
                  },
                  onEndSuccess: () {
                    incomingCallController.trackCallEvent(
                      "callDeclineOption",
                      additionalProperties: {"option": "YES"},
                    );
                    Get.back();
                    incomingCallController.leave(isMe: true);
                  },
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
