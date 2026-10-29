import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/multi_reward_controller.dart';
import 'package:voiceclub_partner/view/rewards/multi_reward/widgets/reward_tile.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class MultiRewardsListScreen extends StatelessWidget {
  const MultiRewardsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    sl<AnalyticsService>().trackEvent("multiRewardsListScreen");
    final multiRewardsController = Get.find<MultiRewardController>();
    return Scaffold(
      appBar: CustomAppBar(title: LocaleKeys.liveSpecialRewards.tr),
      body: SafeArea(
        child: Obx(() {
          final activeRewardsList = multiRewardsController.activeRewardsList;

          if (activeRewardsList.isEmpty) {
            return Center(
              child: Text(LocaleKeys.liveNoActiveRewardsCurrently.tr),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              multiRewardsController.getActiveRewards();
            },
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: activeRewardsList.length,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 16.0),
              itemBuilder: (context, index) {
                final ds = activeRewardsList[index];
                return RewardTile(ds: ds);
              },
            ),
          );
        }),
      ),
    );
  }
}
