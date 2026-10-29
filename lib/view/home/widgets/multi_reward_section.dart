import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/home/widgets/right_arrow_button.dart';
import 'package:voiceclub_partner/view/rewards/multi_reward/multi_rewards_list_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class MultiRewardSection extends StatelessWidget {
  const MultiRewardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const MultiRewardsListScreen());
      },
      child: Stack(
        children: [
          Container(
            height: 100.0,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
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
                      LocaleKeys.homeMultiRewards.tr,
                      style: TextStyle(
                        fontWeight: Weight.bold,
                        fontSize: FontSize.xL,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Image.asset(AssetConstants.multiRewardsTrophy),
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
