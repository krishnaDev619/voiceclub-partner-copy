import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ExcessGiftBottomSheet extends StatelessWidget {
  final int totalEarning;
  final int giftEarning;

  const ExcessGiftBottomSheet({
    super.key,
    required this.totalEarning,
    required this.giftEarning,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: LocaleKeys.liveGiftEarning.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black,
                      fontFamily: GoogleFonts.mulish().fontFamily,
                    ),
                  ),
                  TextSpan(
                    text: LocaleKeys.liveLimitExceeded.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.red,
                      fontFamily: GoogleFonts.mulish().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.warning_rounded, color: Colors.red, size: 120.0),
            const SizedBox(height: 18.0),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.shade200, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total Earning : ',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      Text(
                        '₹$totalEarning',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Gift Earning : ',
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                      Text(
                        '₹$giftEarning',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: LocaleKeys.liveKeepGiftIncomeBelow.tr,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontFamily: GoogleFonts.mulish().fontFamily,
                    ),
                  ),
                  TextSpan(
                    text: '30%',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.mulish().fontFamily,
                    ),
                  ),
                  TextSpan(
                    text: LocaleKeys.liveOrYouWillBe.tr,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontFamily: GoogleFonts.mulish().fontFamily,
                    ),
                  ),
                  TextSpan(
                    text: LocaleKeys.homeStatusFired.tr,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.mulish().fontFamily,
                    ),
                  ),
                  TextSpan(
                    text: LocaleKeys.liveFromTheApp.tr,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontFamily: GoogleFonts.mulish().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18.0),
            CustomButton(
              text: LocaleKeys.liveGotIt.tr,
              onTap: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
