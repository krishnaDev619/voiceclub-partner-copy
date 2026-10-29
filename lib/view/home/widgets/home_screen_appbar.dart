import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/managers_feedback_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/help/help_screen.dart';
import 'package:voiceclub_partner/view/profile/account_screen.dart';
import 'package:voiceclub_partner/view/queries/controller/queries_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/home/home_labels.dart';

class HomeScreenAppBar extends StatefulWidget {
  const HomeScreenAppBar({super.key});

  @override
  State<HomeScreenAppBar> createState() => _HomeScreenAppBarState();
}

class _HomeScreenAppBarState extends State<HomeScreenAppBar> {
  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final managersFeedbackController = Get.find<ManagersFeedbackController>();
    final queriesController = Get.find<QueriesController>();

    return Obx(() {
      final unseenKamQueryChatMessageCount =
          queriesController.unseenKamQueryChatMessageCount.value;
      final meetingCount = userController.meetings.length;
      final managersFeedbackCount =
          managersFeedbackController.managersFeedbackList
              .where((element) => element.addressed == false)
              .length;

      final totalCount =
          unseenKamQueryChatMessageCount +
          meetingCount +
          (userController.showManagersFeedback ? managersFeedbackCount : 0);

      return Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                Get.to(() => const AccountScreen());
              },
              child: Container(
                height: 45.0,
                width: 45.0,
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, color: Colors.white, size: 24.0),
              ),
            ),
            SizedBox(width: 5.0),
            InkWell(
              onTap: () {
                Clipboard.setData(
                  ClipboardData(
                    text:
                        userController.userDetails.value.accountId
                            ?.toString() ??
                        "",
                  ),
                );
                AlertService.showSnackBar(
                  snackBarType: SnackBarType.Success,
                  title: LocaleKeys.homeIdCopied.tr,
                  subtitle: LocaleKeys.homeShareWithManager.tr,
                );
              },
              child: Container(
                width: 85,
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 4.0,
                ),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(5.0),
                    left: Radius.circular(5.0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homePartnerStatusLabel(
                        userController.partnerStatus.value,
                      ),
                      style: TextStyles.buttonText.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.5),
                    Text(
                      LocaleKeys.homeAccountId.trParams({
                        'id':
                            userController.userDetails.value.accountId
                                ?.toString() ??
                            '',
                      }),
                      style: TextStyles.buttonText.copyWith(
                        color: Colors.grey,
                        fontSize: FontSize.M,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),
            GestureDetector(
              onTap: () {
                sl<AnalyticsService>().trackEvent(
                  "helpButtonClick",
                  eventProperties: {
                    "stage": userController.partnerStatus.value.name,
                  },
                );
                Get.to(() => const HelpScreen());
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                          size: 16.0,
                        ),
                        const SizedBox(width: 6.0),
                        Text(LocaleKeys.homeHelp.tr, style: TextStyles.h3),
                      ],
                    ),
                  ),
                  if (totalCount > 0)
                    Positioned(
                      top: -6.0,
                      right: -6.0,
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF4444),
                          shape: BoxShape.circle,
                          // border: Border.all(color: Color(0xFFFF4444), width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            totalCount.toString(),
                            style: TextStyles.h3.copyWith(
                              color: Colors.white,
                              fontSize: 11.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
