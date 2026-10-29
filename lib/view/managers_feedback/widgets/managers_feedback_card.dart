import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/managers_feedback/manager_feedback_model.dart';
import 'package:voiceclub_partner/modules/controller/managers_feedback_controller.dart';
import 'package:voiceclub_partner/view/managers_feedback/widgets/managers_feedback_audio_player.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ManagersFeedbackCard extends StatelessWidget {
  final ManagerFeedbackModel managerFeedback;
  final VoidCallback onCompletion;
  final VoidCallback onIUnderstandClick;

  const ManagersFeedbackCard({
    super.key,
    required this.managerFeedback,
    required this.onCompletion,
    required this.onIUnderstandClick,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      fontSize: FontSize.L,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF5F5E5E),
    );

    final textVerticalSpacing = 6.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      margin: const EdgeInsets.only(top: 16.0),
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        spacing: 12.0,
        children: [
          ManagersFeedbackAudioPlayer(
            audioUrl: managerFeedback.audioUrl ?? "",
            feedbackDate: managerFeedback.createdAt ?? "",
            width: Get.width,
            onCompletion: onCompletion,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                spacing: textVerticalSpacing,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LocaleKeys.liveFeedbackDate.tr, style: textStyle),
                  Text(LocaleKeys.liveManagerSName.tr, style: textStyle),
                ],
              ),
              Column(
                spacing: textVerticalSpacing,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(managerFeedback.formattedCreatedAt, style: textStyle),
                  Text(managerFeedback.managerName ?? "", style: textStyle),
                ],
              ),
            ],
          ),
          if (managerFeedback.addressed == false)
            Obx(() {
              final manageFeedbackController =
                  Get.find<ManagersFeedbackController>();
              final managersFeedbackMap = {
                ...manageFeedbackController.managersFeedbackMap,
              };

              return GestureDetector(
                onTap:
                    managersFeedbackMap[managerFeedback.id] == true
                        ? onIUnderstandClick
                        : null,
                child: Container(
                  margin: const EdgeInsets.only(top: 4.0),
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                  decoration: BoxDecoration(
                    color:
                        managersFeedbackMap[managerFeedback.id ?? 0] == true
                            ? ApplicationColors.primaryRed
                            : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "I Understand",
                    style: TextStyles.h4.copyWith(color: Colors.white),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
