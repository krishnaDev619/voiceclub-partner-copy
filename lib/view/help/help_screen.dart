import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/managers_feedback_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/home/widgets/home_actions_card.dart';
import 'package:voiceclub_partner/view/managers_feedback/managers_feedback_screen.dart';
import 'package:voiceclub_partner/view/meetings/meetings_screen.dart';
import 'package:voiceclub_partner/view/queries/all_queries_screen.dart';
import 'package:voiceclub_partner/view/queries/controller/queries_controller.dart';
import 'package:voiceclub_partner/view/support/support_screen.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final managersFeedbackController = Get.find<ManagersFeedbackController>();
    final queriesController = Get.find<QueriesController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: LocaleKeys.homeHelp.tr,
        centerTitle: true,
        titleFontSize: FontSize.xL,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            Obx(() {
              return HomeActionCard(
                title: LocaleKeys.liveAllQueries.tr,
                icon: Icons.chat,
                pendingCount:
                    queriesController.unseenKamQueryChatMessageCount.value,
                onTap: () {
                  Get.to(() => const AllQueriesScreen());
                  sl<AnalyticsService>().trackEvent(
                    "chatWithManagerButtonClick",
                    eventProperties: {
                      "stage": userController.partnerStatus.value.name,
                    },
                  );
                },
              );
            }),
            HomeActionCard(
              title: LocaleKeys.liveMeetings.tr,
              icon: Icons.videocam_rounded,
              pendingCount:
                  userController.meetingSchedule.value?.meetings?.length,
              onTap: () => Get.to(() => const MeetingsScreen()),
            ),
            if (userController.showManagersFeedback)
              HomeActionCard(
                title: LocaleKeys.liveFeedback.tr,
                icon: Icons.person,
                pendingCount: managersFeedbackController.pendingFeedbackCount,
                onTap: () => Get.to(() => const ManagersFeedbackScreen()),
              ),
            HomeActionCard(
              title: LocaleKeys.liveFaqs.tr,
              icon: Icons.help,
              onTap: SupportScreen.show,
            ),
          ],
        ),
      ),
    );
  }
}
