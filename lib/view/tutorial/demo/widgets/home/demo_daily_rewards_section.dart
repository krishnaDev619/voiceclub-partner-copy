import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_daily_rewards_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoDailyRewardsSection extends StatefulWidget {
  const DemoDailyRewardsSection({super.key});

  @override
  State<DemoDailyRewardsSection> createState() =>
      _DemoDailyRewardsSectionState();
}

class _DemoDailyRewardsSectionState extends State<DemoDailyRewardsSection> {
  String formatTimeToHoursMinutes(int seconds) {
    if (seconds < 3600) {
      final minutes = (seconds ~/ 60);
      return LocaleKeys.demoMinsShort.trParams({'minutes': '$minutes'});
    } else {
      final hours = (seconds / 3600).floor();
      return LocaleKeys.demoHoursMins.trParams({'hours': '$hours'});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const DemoDailyRewardsScreen());
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFFF9B6D), Color(0xFFFF7777)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4.0,
              spreadRadius: 0.4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100.0,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 12.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        LocaleKeys.demoDailyRewards.tr,
                        style: TextStyle(
                          fontWeight: Weight.bold,
                          fontSize: FontSize.xL,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Image.asset(AssetConstants.dailyRewardsBg),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.demoSeeAll.tr,
                    style: TextStyle(fontSize: FontSize.S, color: Colors.white),
                  ),
                  Icon(
                    Icons.arrow_circle_right_rounded,
                    size: 18.0,
                    color: Colors.white,
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
