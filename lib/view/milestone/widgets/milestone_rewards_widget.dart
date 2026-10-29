import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/modules/controller/wallet_controller.dart';

class MilestoneRewardsWidget extends StatelessWidget {
  const MilestoneRewardsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.find<WalletController>().fetchAndShowMiletoneEarnings(),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: const Color(0xFFFFF9F6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Stack(
          children: [
            SvgPicture.asset(AssetConstants.bigRewardsBg),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.liveYearlyAndLifetimeRewards.tr,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: FontSize.xL,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD9D8),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 6.0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                LocaleKeys.liveExploreNow.tr,
                                style: const TextStyle(
                                  fontWeight: Weight.heavy,
                                ),
                              ),
                              SizedBox(width: 6.0),
                              CircleAvatar(
                                radius: 12.0,
                                child: Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Image.asset(
                      AssetConstants.walletRupee,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
