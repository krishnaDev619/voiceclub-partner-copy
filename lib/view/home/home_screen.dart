import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/config_fcm_service.dart';
import 'package:voiceclub_partner/modules/controller/managers_feedback_controller.dart';
import 'package:voiceclub_partner/modules/controller/multi_reward_controller.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/modules/controller/tier_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/modules/controller/wallet_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/send_new_user_audio_carousel.dart';
import 'package:voiceclub_partner/view/home/widgets/achievements_section.dart';
import 'package:voiceclub_partner/view/home/widgets/activity_status_widget.dart';
import 'package:voiceclub_partner/view/home/widgets/firing_alert.dart';
import 'package:voiceclub_partner/view/home/widgets/home_screen_appbar.dart';
import 'package:voiceclub_partner/view/home/widgets/query_section.dart';
import 'package:voiceclub_partner/view/home/widgets/rewards_section.dart';
import 'package:voiceclub_partner/view/home/widgets/verify_account_button.dart';
import 'package:voiceclub_partner/view/home/widgets/wallet_details_widget.dart';
import 'package:voiceclub_partner/view/landing/landing_controller.dart';
import 'package:voiceclub_partner/view/logs/logs_controller.dart';
import 'package:voiceclub_partner/view/queries/controller/queries_controller.dart';

class HomeScreen extends StatefulWidget {
  final void Function(BottomBarTabType) changeTab;

  const HomeScreen({super.key, required this.changeTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supplyWalletController = Get.find<WalletController>();
  final userController = Get.find<UserController>();

  // final supplyStoryController = Get.find<StoryController>();
  final supplyLogsController = Get.find<LogsController>();
  final tierController = Get.find<TierController>();
  final probationController = Get.find<ProbationController>();
  final managersFeedbackController = Get.find<ManagersFeedbackController>();
  final queriesController = Get.find<QueriesController>();

  @override
  void initState() {
    getHomeData(isInit: true);

    super.initState();
  }

  Future<void> getHomeData({
    bool isRefresh = false,
    bool isInit = false,
  }) async {
    try {
      await probationController.fetchProbationDetails(
        fetchMetrics: true,
        scoreOnly: true,
      );
      if (!isInit) {
        await userController.fetchData(fetchOnlineDuration: true);
        if (userController.showManagersFeedback) {
          await managersFeedbackController.getManagersFeedback();
        }
        // supplyStoryController.fetchStory();
        supplyWalletController.fetchData();
        supplyWalletController.fetchCoinBalance();
        await tierController.fetchData();
        await supplyLogsController.fetchLogs();
        await Get.find<MultiRewardController>().getActiveRewards();
        Get.find<LandingController>().checkRewardsEnabled();
        ConfigFCMService.updateFCM();
        queriesController.fetchUnseenKamQueryChatMessageCount();
      }
    } catch (_) {
    } finally {
      setState(() {});
      if (isRefresh) {
        if (userController.showManagersFeedback) {
          await managersFeedbackController.getManagersFeedback();
        }
        sl<AnalyticsService>().trackEvent(
          'refreshHomeScreenPartner',
          eventProperties: eventProperties,
        );
      } else {
        sl<AnalyticsService>().trackEvent(
          'partnerHomeScreen',
          eventProperties: eventProperties,
        );
      }
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Map<String, Object?> get eventProperties => {
    'currentBalance': supplyWalletController.finalValue.value,
    'weeklyOnlineDuration':
        tierController.weeklyOnlineDuration.value.getThisWeekOnlineDuration /
        60,
    'currentStatus': userController.userDetails.value.status,
    if (probationController.probationDetails.value.stage ==
            PartnerCurrentStatus.LIVE ||
        probationController.probationDetails.value.stage ==
            PartnerCurrentStatus.NEW_LIVE ||
        probationController.probationDetails.value.stage ==
            PartnerCurrentStatus.PROBATION)
      'oneScore':
          probationController.metricsData.value.aggregate?.score?.toInt(),
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F9),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                await getHomeData(isRefresh: true);
              },
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    const HomeScreenAppBar(),
                    const SizedBox(height: 36.0),
                    const WalletDetailsWidget(),
                    const VerifyAccountButton(),
                    const ActivityStatusWidget(),
                    const SendNewUserAudioCarousel(isHomeScreen: true),
                    const FiringAlert(),
                    const RewardsSection(),
                    const AchievementsSection(),
                    // OverviewWidgetCard(changeTab: widget.changeTab),
                    const SizedBox(height: 100.0),
                  ],
                ),
              ),
            ),
            const QuerySection(),
          ],
        ),
      ),
    );
  }
}
