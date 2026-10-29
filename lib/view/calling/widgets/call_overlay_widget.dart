import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/calls/incoming_call_controller.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_end_button.dart';
import 'package:voiceclub_partner/view/calling/widgets/call_mute_button.dart';

class CallOverlayWidget extends StatelessWidget {
  const CallOverlayWidget({super.key});

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  @override
  Widget build(BuildContext context) {
    final incomingCallController = Get.find<IncomingCallController>();
    final size = (Get.width - 80.0) / 7;
    const green = Colors.green;
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16.0),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16.0),
            bottomRight: Radius.circular(16.0),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.call_rounded, color: green, size: 16.0),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        "${incomingCallController.name} - ",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: green,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.M,
                        ),
                      ),
                    ),
                    Text(
                      formatTime(
                        incomingCallController.callDurationSeconds.value,
                      ),
                      style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize.M,
                      ),
                    ),
                  ],
                ),
              ),
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
      );
    });
  }
}
