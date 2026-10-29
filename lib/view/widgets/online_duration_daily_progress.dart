import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class OnlineDurationDailyProgress extends StatelessWidget {
  final num calls;
  final String day;
  const OnlineDurationDailyProgress({
    super.key,
    required this.calls,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final value = (calls.floor() >= 4) ? 1.0 : (calls.floor() / 4);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotatedBox(
          quarterTurns: 3,
          child: SizedBox(
            width: 48.0,
            height: 12.0,
            child: LinearProgressIndicator(
              value: value,
              color: Get.theme.primaryColor,
              borderRadius: BorderRadius.circular(12.0),
              backgroundColor: const Color(0xFFFEE0E0),
            ),
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          day,
          style: const TextStyle(
            fontSize: FontSize.S,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
