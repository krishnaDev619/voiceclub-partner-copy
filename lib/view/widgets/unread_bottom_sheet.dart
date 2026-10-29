import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/view/landing/landing_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class UnreadBottomSheet extends StatelessWidget {
  final String message;

  const UnreadBottomSheet({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    sl<AnalyticsService>().trackEvent(
      "partnerBottomSheetOpen",
      eventProperties: {
        "bottomSheetType": "UnreadBottomSheet",
        "unreadCount": Get.find<ChatOverviewController>().unseenCount.value,
      },
    );
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 16.0,
              bottom: 8.0,
            ),
            width: MediaQuery.of(context).size.width,
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Can't go online!",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Get.theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: FontSize.xXXL,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: FontSize.xL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CustomButton(
                  text: LocaleKeys.liveViewMessages.tr,
                  onTap: () {
                    Get.back();
                    Get.find<LandingController>().changeTab(
                      BottomBarTabType.CHATS,
                      isUnread: true,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
