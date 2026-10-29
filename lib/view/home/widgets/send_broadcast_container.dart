import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/chat_filter_bottom_sheet.dart';
import 'package:voiceclub_partner/view/landing/landing_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class SendBroadcastContainer extends StatelessWidget {
  const SendBroadcastContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatOverviewController>(
      builder: (controller) {
        if (controller.pendingAudios.isNotEmpty) {
          final count = controller.pendingAudios.length;
          return Container(
            height: 132.0,
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
              border: Border.all(color: Get.theme.primaryColor, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: Get.theme.primaryColor,
                      width: 2.0,
                    ),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: Get.theme.primaryColor,
                      fontSize: FontSize.xXXXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        LocaleKeys.homeAudiosLeft.tr,
                        style: TextStyle(
                          fontSize: FontSize.xXL,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      InkWell(
                        onTap: () {
                          Get.find<LandingController>().changeTab(
                            BottomBarTabType.CHATS,
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            LocaleKeys.homeSendAudio.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: FontSize.L,
                              fontWeight: FontWeight.bold,
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
        } else {
          return Container(
            height: 132.0,
            margin: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: Colors.white,
              border: Border.all(color: Get.theme.primaryColor, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Get.theme.primaryColor,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 32.0),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        LocaleKeys.homeSendBroadcast.tr,
                        style: TextStyle(
                          fontSize: FontSize.xXL,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      InkWell(
                        onTap: () {
                          Get.find<LandingController>().changeTab(
                            BottomBarTabType.CHATS,
                          );
                          Get.bottomSheet(const ChatFilterBottomSheet());
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          decoration: BoxDecoration(
                            color: Get.theme.primaryColor,
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            LocaleKeys.homeSend.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: FontSize.L,
                              fontWeight: FontWeight.bold,
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
        }
      },
    );
  }
}
