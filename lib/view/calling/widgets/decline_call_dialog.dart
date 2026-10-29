import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DeclineCallDialog extends StatelessWidget {
  final int rejectedCallCount;
  final bool isNew;
  final VoidCallback leaveFunction;

  const DeclineCallDialog({
    super.key,
    required this.rejectedCallCount,
    required this.isNew,
    required this.leaveFunction,
  });

  String getDisplayString() {
    const allowedCount = 3;
    final rejectsLeft =
        rejectedCallCount > allowedCount
            ? 0
            : (allowedCount - rejectedCallCount);
    if (rejectsLeft <= 0) {
      return LocaleKeys.livePenaltyDeducted.tr;
    }
    if (rejectsLeft == 1) {
      return LocaleKeys.livePenaltyAfterCall.trParams({
        'count': '$rejectsLeft',
      });
    }
    return LocaleKeys.livePenaltyAfterCalls.trParams({'count': '$rejectsLeft'});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        LocaleKeys.liveDeclineCallConfirm.tr,
        style: const TextStyle(
          fontSize: FontSize.L,
          fontWeight: FontWeight.bold,
        ),
      ),
      contentPadding: const EdgeInsets.only(
        top: 12.0,
        left: 24.0,
        right: 24.0,
        bottom: 0.0,
      ),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 18.0,
          ),
          const SizedBox(width: 4.0),
          Expanded(
            child: Text(
              getDisplayString(),
              style: const TextStyle(
                fontSize: FontSize.L,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
            leaveFunction();
          },
          child: Text(
            LocaleKeys.liveYes.tr,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: FontSize.L,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            sl<AnalyticsService>().trackEvent(
              "callDeclineOption",
              eventProperties: {"option": "NO"},
            );
            Get.back();
          },
          child: Text(
            LocaleKeys.liveNo.tr,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: FontSize.L,
            ),
          ),
        ),
      ],
    );
  }
}
