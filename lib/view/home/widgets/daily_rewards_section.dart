import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/home/widgets/right_arrow_button.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/daily_rewards_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DailyRewardsSection extends StatefulWidget {
  const DailyRewardsSection({super.key});

  @override
  State<DailyRewardsSection> createState() => _DailyRewardsSectionState();
}

class _DailyRewardsSectionState extends State<DailyRewardsSection> {
  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return GestureDetector(
      onTap: () {
        userController.getOnlineDuration();
        Get.to(() => const DailyRewardsScreen());
      },
      child: Stack(
        children: [
          Container(
            height: 100.0,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4.0,
                  spreadRadius: 0.4,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      LocaleKeys.homeDailyRewards.tr,
                      style: TextStyle(
                        fontWeight: Weight.bold,
                        fontSize: FontSize.xL,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Image.asset(AssetConstants.dailyRewardsBg),
                ),
              ],
            ),
          ),
          const Positioned(
            right: 8.0,
            top: 8.0,
            child: RightArrowButton(size: 20.0),
          ),
        ],
      ),
    );
  }
}
