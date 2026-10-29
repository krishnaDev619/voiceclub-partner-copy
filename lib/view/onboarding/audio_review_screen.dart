import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class AudioReviewScreen extends StatelessWidget {
  const AudioReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                Column(
                  children: [
                    SvgPicture.asset(AssetConstants.audioReview),
                    const SizedBox(height: 40.0),
                    Text(
                      LocaleKeys.audiosSentForApproval.tr,
                      style: const TextStyle(
                        fontSize: FontSize.xXXL,
                        fontWeight: Weight.heavy,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                CustomButton(
                  text: LocaleKeys.proceedNext.tr,
                  onTap: () {
                    Get.back();
                  },
                ),
              ],
            ),
            Lottie.asset(AssetConstants.confettiAnimation),
          ],
        ),
      ),
    );
  }
}
