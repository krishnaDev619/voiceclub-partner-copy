import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/account/rewards_stats.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/widgets/rewards_progress_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoChatRewards extends StatefulWidget {
  final IncentiveCalls chatReceived;
  const DemoChatRewards({super.key, required this.chatReceived});

  @override
  State<DemoChatRewards> createState() => _DemoChatRewardsState();
}

class _DemoChatRewardsState extends State<DemoChatRewards> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.demoChatRewards.tr,
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
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            RewardsProgressBar(
              rewards: widget.chatReceived,
              type: RewardsProgressBarType.chatRewards,
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
