import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ReviewVoiceClubAlert extends StatelessWidget {
  const ReviewVoiceClubAlert({super.key});
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Enjoying VoiceClub?",
            style: TextStyle(
              color: Get.theme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4.0),
          Icon(Icons.favorite, color: Get.theme.primaryColor),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "PlayStore par humein rate karein aur apna feedback dein.",
          ),
          const SizedBox(height: 20.0),
          CustomButton(
            text: LocaleKeys.liveRateUs.tr,
            onTap: () async {
              Get.back(result: true);
            },
          ),
        ],
      ),
    );
  }
}
