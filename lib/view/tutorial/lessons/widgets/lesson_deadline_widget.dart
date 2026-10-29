import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class LessonDeadlineWidget extends StatelessWidget {
  const LessonDeadlineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const redColor = Color(0xFFFF1717);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: const Border(
          top: BorderSide(color: redColor, width: 1.5),
          bottom: BorderSide(color: redColor, width: 1.5),
        ),
        color: redColor.withValues(alpha: 0.1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            LocaleKeys.demoCompleteCourse.tr,
            style: TextStyle(
              color: redColor,
              fontWeight: Weight.heavy,
              fontSize: FontSize.xL,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            LocaleKeys.demoHoursLeftSample.tr,
            style: TextStyle(fontSize: FontSize.L, color: redColor),
          ),
        ],
      ),
    );
  }
}
