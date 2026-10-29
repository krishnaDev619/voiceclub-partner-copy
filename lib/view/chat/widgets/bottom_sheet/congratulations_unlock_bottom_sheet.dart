import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CongratulationsUnlockBottomSheet extends StatelessWidget {
  const CongratulationsUnlockBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 4.0),
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 28.0,
              horizontal: 12.0,
            ),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFF1E4B6B), Color(0xFF172937)],
                stops: [0.3484, 1.0],
                transform: GradientRotation(213.98),
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 108.0,
                  child: Image.asset(
                    AssetConstants.congratulations,
                    height: 108.0,
                  ),
                ),
                const SizedBox(height: 24.0),
                const Text(
                  'Congratulations!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: FontSize.xXXXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: LocaleKeys.liveYouVeNowUnlocked.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: FontSize.xL,
                        ),
                      ),
                      TextSpan(
                        text: LocaleKeys.liveChat.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
