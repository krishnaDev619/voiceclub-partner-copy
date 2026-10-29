import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CallDetailsBottomSheet extends StatelessWidget {
  final String totalCalls;
  final int totalCallDuration;
  final String currentCall;
  final int durationToConvert;
  final String userName;
  final String label;

  const CallDetailsBottomSheet({
    super.key,
    required this.totalCalls,
    required this.totalCallDuration,
    required this.currentCall,
    required this.durationToConvert,
    required this.userName,
    required this.label,
  });

  String formatTime(int seconds) {
    final hours = (seconds ~/ 3600);
    final minutes = ((seconds % 3600) ~/ 60);
    final remainingSeconds = seconds % 60;

    final formattedHours = hours.toString().padLeft(2, '0');
    final formattedMinutes = minutes.toString().padLeft(2, '0');
    final formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

    return "${hours > 0 ? '${formattedHours}h ' : ''}${formattedMinutes}m ${formattedSeconds}s";
  }

  // String formatDate(PerformanceData? data) {
  //   final startDate =
  //       DateTime.tryParse(data?.startedAt ?? DateTime.now().toIso8601String())
  //               ?.toLocal() ??
  //           DateTime.now().toLocal();
  //   final endDate =
  //       DateTime.tryParse(data?.endedAt ?? DateTime.now().toIso8601String())
  //               ?.toLocal() ??
  //           DateTime.now().toLocal();

  //   final formattedDate =
  //       "(${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)})";

  //   return formattedDate;
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: FontSize.xXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: FontSize.M,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(LocaleKeys.liveTotalCallDuration.tr),
                Text(
                  formatTime(totalCallDuration),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
