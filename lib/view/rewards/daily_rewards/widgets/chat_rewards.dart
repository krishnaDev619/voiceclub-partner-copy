import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/account/rewards_stats.dart';
import 'package:voiceclub_partner/modules/controller/rewards_controller.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/widgets/chat_reward_info_banner.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/widgets/rewards_progress_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ChatRewards extends StatefulWidget {
  const ChatRewards({super.key});

  @override
  State<ChatRewards> createState() => _ChatRewardsState();
}

class _ChatRewardsState extends State<ChatRewards> {
  final rewardsController = Get.find<RewardsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.liveChatRewards.tr,
          style: TextStyle(
            fontWeight: Weight.heavy,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Visibility(
          visible: rewardsController.rewardsStats.value?.chatReceived != null,
          replacement: Text(LocaleKeys.liveNoRewardsData.tr),
          child: Column(
            children: [
              RewardsProgressBar(
                rewards:
                    rewardsController.rewardsStats.value?.chatReceived ??
                    IncentiveCalls(),
                type: RewardsProgressBarType.chatRewards,
              ),
              const ChatRewardInfoBanner(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
