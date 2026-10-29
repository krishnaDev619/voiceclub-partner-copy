import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/calling_service.dart';
import 'package:voiceclub_partner/data/models/calling/get_reverse_calling_stats_reponse.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class FirstCallBottomSheet extends StatelessWidget {
  final String userName;
  final GetReverseCallingStatsResponseModel reverseCallingStatsResponse;
  final ChatMember demandPeer;
  final int chatGroupId;

  const FirstCallBottomSheet({
    super.key,
    required this.userName,
    required this.reverseCallingStatsResponse,
    required this.demandPeer,
    required this.chatGroupId,
  });

  @override
  Widget build(BuildContext context) {
    sl<AnalyticsService>().trackEvent(
      "firstCallBottomSheet",
      eventProperties: {
        "demandAccountId": demandPeer.accountId,
        "demandPeerName": demandPeer.user?.name,
        "chatGroupId": chatGroupId,
        "demandNumber": demandPeer.user?.phoneNumber,
      },
    );
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title text
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  height: 1.3,
                ),
                children: [
                  TextSpan(text: LocaleKeys.liveNoOneHasCalled.tr),
                  TextSpan(
                    text: userName,
                    style: TextStyle(
                      color: Get.theme.primaryColor, // Pinkish color for name
                    ),
                  ),
                  TextSpan(text: LocaleKeys.liveYet.tr),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              "You can be the first!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Sad user image with thought bubble
            Image.asset(AssetConstants.sadUser, fit: BoxFit.cover, height: 200),

            const SizedBox(height: 40),

            // Call Now button
            CustomButton(
              text: LocaleKeys.liveCallNow.tr,
              onTap: () {
                Get.back();
                CallingService().call(
                  demandUser: demandPeer.user ?? UserDataModel(),
                  demandAccountId: demandPeer.accountId ?? 0,
                  chatGroupId: chatGroupId,
                  screenName: "FirstCallBottomSheet",
                );
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
