import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/view/widgets/gradient_text.dart';

class MilestoneGiftPopup extends StatelessWidget {
  final String gift;
  final String assetPath;
  final bool isYearly;

  const MilestoneGiftPopup({
    super.key,
    required this.assetPath,
    required this.gift,
    this.isYearly = false,
  });

  @override
  Widget build(BuildContext context) {
    sl<AnalyticsService>().trackEvent(
      "milestoneGiftPopup",
      eventProperties: {"gift": gift},
    );
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SvgPicture.asset(AssetConstants.congratulationsBg),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: GradientText(
                    LocaleKeys.liveCongratulations.tr,
                    gradient: Gradients.primaryGradient(),
                    style: const TextStyle(
                      fontWeight: Weight.bold,
                      fontSize: FontSize.xXL,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  child: Text(
                    LocaleKeys.liveYouWillReceiveGiftAsGift.trParams({
                      'gift': gift,
                    }),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF5B5B5B)),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AssetConstants.congratulationsGirl,
                      height: 160.0,
                      width: 160.0,
                      fit: BoxFit.contain,
                    ),
                    isYearly
                        ? FastCachedImage(
                          url: assetPath,
                          height: 110.0,
                          width: 100.0,
                          fit: BoxFit.contain,
                        )
                        : Image.asset(
                          assetPath,
                          height: 110.0,
                          width: 100.0,
                          fit: BoxFit.contain,
                        ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
