import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/online_user_circle.dart';

class ActiveChatsCarousel extends StatelessWidget {
  const ActiveChatsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatOverviewController>();
    return Obx(() {
      final activeUsers = controller.activeUsers.toList();
      return Visibility(
        visible: activeUsers.isNotEmpty,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 6.0,
                    backgroundColor: Colors.green,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    LocaleKeys.liveOnlineToday.tr,
                    style: const TextStyle(
                      fontSize: FontSize.xXXL,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 80.0,
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                itemCount: activeUsers.length,
                itemBuilder: (context, index) {
                  final activeAccount = activeUsers[index];
                  return OnlineUserCircle(activeAccount: activeAccount);
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
