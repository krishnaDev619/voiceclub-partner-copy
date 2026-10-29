import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class StepWidget {
  final String title;
  final String subtitle;
  final RecordingAudioStatus approvalStatus;
  final bool isCompleted;
  final OnboardingStep stepIndex;
  final OnboardingStep currentStep;

  StepWidget({
    required this.title,
    required this.subtitle,
    required this.approvalStatus,
    required this.isCompleted,
    required this.stepIndex,
    required this.currentStep,
  });

  // Overloading the call method so that the class instance acts like a function
  Step buildStep() {
    final state =
        isCompleted
            ? approvalStatus == RecordingAudioStatus.Rejected
                ? StepState.error
                : StepState.complete
            : StepState.indexed;

    return Step(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: FontSize.L,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 4.0),
          if (isCompleted) approvalStatus.getStatusChip(),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          subtitle,
          style: TextStyle(
            fontSize: FontSize.M,
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
      ),
      content: const SizedBox.shrink(),
      isActive: currentStep == stepIndex || isCompleted,
      state: state,
    );
  }
}
