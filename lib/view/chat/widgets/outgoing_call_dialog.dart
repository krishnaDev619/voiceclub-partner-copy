import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/calling_service.dart';
import 'package:voiceclub_partner/data/models/calling/get_reverse_calling_stats_reponse.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class OutgoingCallDialog extends StatelessWidget {
  final GetReverseCallingStatsResponseModel reverseCallingStatsResponse;
  final ChatMember demandPeer;
  final int? chatGroupId;
  final String screenName;

  const OutgoingCallDialog({
    super.key,
    required this.reverseCallingStatsResponse,
    required this.demandPeer,
    required this.screenName,
    this.chatGroupId,
  });

  String formatTime(int seconds) {
    if (seconds < 0) {
      return "0 secs";
    }

    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    String minutesPart = minutes > 0 ? "$minutes mins" : "";
    String secondsPart = remainingSeconds > 0 ? "$remainingSeconds secs" : "";

    if (minutesPart.isEmpty && secondsPart.isEmpty) {
      return "0 secs";
    } else if (minutesPart.isNotEmpty && secondsPart.isNotEmpty) {
      return "$minutesPart $secondsPart";
    } else {
      return minutesPart.isNotEmpty ? minutesPart : secondsPart;
    }
  }

  @override
  Widget build(BuildContext context) {
    int remainingCalls =
        (reverseCallingStatsResponse.maxCount ?? 0) -
        (reverseCallingStatsResponse.count ?? 0);
    remainingCalls = remainingCalls < 0 ? 0 : remainingCalls;
    final isCallAllowed =
        (remainingCalls > 0 &&
            reverseCallingStatsResponse.isCallAllowed == true) ||
        reverseCallingStatsResponse.hasRecharged;
    return AlertDialog(
      insetPadding: const EdgeInsets.all(8.0),
      contentPadding: const EdgeInsets.all(16.0),
      iconPadding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const Icon(Icons.close),
            ),
          ),
          CustomProfilePicture(
            avatarURL: demandPeer.user?.avatar,
            name: demandPeer.user?.name,
            radius: 58.0,
          ),
          const SizedBox(height: 12.0),
          if (!reverseCallingStatsResponse.hasRecharged) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.call_rounded,
                  size: 18.0,
                  color: Get.theme.primaryColor,
                ),
                const SizedBox(width: 4.0),
                Text(
                  "$remainingCalls calls remaining",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 18.0,
                  color: Get.theme.primaryColor,
                ),
                const SizedBox(width: 4.0),
                Text(
                  "Each call is ${formatTime(reverseCallingStatsResponse.duration ?? 120)} only",
                  style: const TextStyle(fontSize: FontSize.M),
                ),
              ],
            ),
          ] else ...[
            Text(
              "Talk to ${demandPeer.user?.name} ${formatTime(reverseCallingStatsResponse.rechargedDuration ?? 0)} remaining",
              style: const TextStyle(fontSize: FontSize.M),
            ),
          ],
          const SizedBox(height: 16.0),
          Opacity(
            opacity: isCallAllowed ? 1.0 : 0.5,
            child: CustomButton(
              text: LocaleKeys.liveCallNow.tr,
              onTap: () {
                if (isCallAllowed) {
                  Get.back();
                  CallingService().call(
                    demandUser: demandPeer.user ?? UserDataModel(),
                    demandAccountId: demandPeer.accountId ?? 0,
                    chatGroupId: chatGroupId,
                    screenName: screenName,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
