import 'package:flutter/material.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class ChatRewardInfoBanner extends StatelessWidget {
  const ChatRewardInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFEE6464), width: 0.4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.black,
            size: 18.0,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 13.0,
                  color: Colors.black87,
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: LocaleKeys.liveRewardIsGivenOnlyFor.tr),
                  TextSpan(
                    text: LocaleKeys.liveReceivedMessages.tr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: LocaleKeys.liveNotSentMessages.tr),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
