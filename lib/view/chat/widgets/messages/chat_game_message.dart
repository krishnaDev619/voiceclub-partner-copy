import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_reverse_calling_stats.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_timestamp_widget.dart';
import 'package:voiceclub_partner/view/chat/widgets/outgoing_call_dialog.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ChatGameMessage extends StatelessWidget {
  final DateTime time;
  final ChatMember supply;
  final CategoryCode category;
  final DateTime createdAt;
  final bool sentByMe;
  final ChatTheme theme;
  final int chatGroupId;
  final String messageId;
  final String content;

  const ChatGameMessage({
    super.key,
    required this.createdAt,
    required this.supply,
    required this.category,
    required this.time,
    required this.sentByMe,
    required this.theme,
    required this.chatGroupId,
    required this.messageId,
    required this.content,
  });

  void openReverseCallDialog() async {
    try {
      Get.context?.loaderOverlay.show();
      var response = await sl<GetReverseCallingStatsUsecase>().call(
        GetReverseCallingStatsParams(demandAccountId: supply.accountId ?? 0),
      );
      if (response.data != null && response.error == null) {
        final reverseCallingStatsResponse = response.data;
        if (reverseCallingStatsResponse != null) {
          HapticFeedback.vibrate();
          Get.dialog(
            OutgoingCallDialog(
              reverseCallingStatsResponse: reverseCallingStatsResponse,
              demandPeer: ChatMember(
                accountId: supply.accountId ?? 0,
                user: supply.user,
              ),
              screenName: "ChatGameMessage",
            ),
          );
        } else {
          outgoingCallFailedSnackbar();
        }
      } else {
        outgoingCallFailedSnackbar();
      }
    } catch (_) {
      outgoingCallFailedSnackbar();
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  void outgoingCallFailedSnackbar() {
    AlertService.showSnackBar(
      snackBarType: SnackBarType.Error,
      title: LocaleKeys.liveCallFailed.tr,
      subtitle: LocaleKeys.livePleaseTryAgainLater.tr,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.secondaryBubbleColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Container(
                  width: double.infinity,
                  height: 200.0,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage(AssetConstants.playedGame),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: FontSize.L,
                      fontWeight: FontWeight.bold,
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                ),
                CustomButton(
                  text: LocaleKeys.liveCallNow.tr,
                  onTap: () {
                    openReverseCallDialog();
                  },
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ChatTimestampWidget(
                    key: UniqueKey(),
                    timestamp: time,
                    sentByMe: sentByMe,
                    chatGroupId: chatGroupId,
                    color: const Color(0xFF999999),
                    messageId: messageId,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
