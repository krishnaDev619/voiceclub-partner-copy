import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_send_new_user_audio_carousel.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/home/demo_activity_status_widget.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/home/demo_daily_rewards_section.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/home/demo_home_screen_appbar.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/home/demo_metrics_section.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/home/demo_wallet_details_widget.dart';

class DemoHomeScreen extends StatelessWidget {
  const DemoHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final demoController = Get.find<DemoLandingController>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: demoController.homeScrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                const DemoHomeScreenAppBar(),
                const SizedBox(height: 36.0),
                const DemoWalletDetailsWidget(),
                const SizedBox(height: 14.0),
                const DemoActivityStatusWidget(),
                const DemoSendNewUserAudioCarousel(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Disabled(
                          disabled: demoController.currentStage.isLessThan(
                            TutorialStage.S3,
                          ),
                          child: const DemoDailyRewardsSection(),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Expanded(child: DemoMetricsSection()),
                    ],
                  ),
                ),
                // Disabled(
                //   disabled:
                //       demoController.currentStage.isLessThan(TutorialStage.S10),
                //   child: const NewUserCallsSection(),
                // ),
                // const DemoOverviewWidget(),
                const SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
