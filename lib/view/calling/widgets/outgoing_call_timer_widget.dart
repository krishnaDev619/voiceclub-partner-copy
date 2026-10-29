import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class OutgoingCallTimerWidget extends StatelessWidget {
  final bool isAccepted;
  final RingState? ringState;
  final int countDownSeconds;
  final int callOnlySeconds;
  final bool remoteUserMute;
  const OutgoingCallTimerWidget({
    super.key,
    required this.isAccepted,
    required this.ringState,
    required this.countDownSeconds,
    required this.callOnlySeconds,
    required this.remoteUserMute,
  });

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isAccepted,
      replacement: Text(
        "${ringState?.name.toLowerCase() ?? "Calling"}...",
        style: const TextStyle(color: Colors.black54),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${formatTime(countDownSeconds)} minutes remaining",
            style: const TextStyle(color: Colors.black),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 20.0,
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40.0,
              child: LinearProgressIndicator(
                value: (callOnlySeconds - countDownSeconds) / callOnlySeconds,
                color: Get.theme.primaryColor,
                minHeight: 6.0,
                backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          Visibility(
            visible: remoteUserMute,
            child: Text(
              LocaleKeys.liveMuted.tr,
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
