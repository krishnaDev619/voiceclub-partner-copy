import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/demo_question_widget.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/daily_rewards/demo_today_earning_section.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoDailyRewardsScreen extends StatefulWidget {
  const DemoDailyRewardsScreen({super.key});

  @override
  State<DemoDailyRewardsScreen> createState() => _DemoDailyRewardsScreenState();
}

class _DemoDailyRewardsScreenState extends State<DemoDailyRewardsScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    Get.find<DemoLandingController>().validateAction(
      TutorialDemoFeature.DAILY_REWARD_CRITERIA,
    );
  }

  String getRewardsDate() {
    return DateFormat('dd MMM yyyy').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final demoController = Get.find<DemoLandingController>();
    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.demoDailyRewardsTitle.tr,
        subtitle: LocaleKeys.demoRewardsDate.trParams({
          'date': getRewardsDate(),
        }),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            DemoTodayEarningSection(key: UniqueKey()),
            Align(
              alignment: Alignment.bottomCenter,
              child: Obx(
                () => DemoQuestionWidget(
                  question: demoController.currentQuestion,
                  totalQuestions: demoController.demoQuestions.length,
                  currentQuestionIndex:
                      demoController.currentQuestionIndex.value,
                  isTopView: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
