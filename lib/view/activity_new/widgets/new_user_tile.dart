import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/data/models/account/conversion_user.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_reverse_calling_stats.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_conversion_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/outgoing_call_dialog.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class NewUserTileWidget extends StatelessWidget {
  final ConversionUser user;
  final int cutoffSeconds;
  final String screenName;

  const NewUserTileWidget({
    super.key,
    required this.user,
    required this.cutoffSeconds,
    required this.screenName,
  });

  String get getCutoffMinutes {
    var durationInSeconds = cutoffSeconds - (user.duration ?? 0);
    var durationInMinutes = durationInSeconds / 60;
    int remainingSeconds = durationInSeconds % 60;
    return "${durationInMinutes.floor().toStringAsFixed(0)}:${remainingSeconds.toString().padLeft(2, '0')} min";
  }

  String get getDurationInMinutes {
    var durationInSeconds = user.duration ?? 0;
    var durationInMinutes = durationInSeconds / 60;
    int remainingSeconds = durationInSeconds % 60;
    return "${durationInMinutes.floor().toStringAsFixed(0)}:${remainingSeconds.toString().padLeft(2, '0')} min";
  }

  void openReverseCallDialog() async {
    try {
      Get.context?.loaderOverlay.show();
      var response = await sl<GetReverseCallingStatsUsecase>().call(
        GetReverseCallingStatsParams(demandAccountId: user.accountId ?? 0),
      );
      if (response.data != null && response.error == null) {
        final reverseCallingStatsResponse = response.data;
        if (reverseCallingStatsResponse != null) {
          HapticFeedback.vibrate();
          Get.dialog(
            OutgoingCallDialog(
              reverseCallingStatsResponse: reverseCallingStatsResponse,
              demandPeer: ChatMember(
                accountId: user.accountId ?? 0,
                user: user.user,
              ),
              screenName: screenName,
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
    return SizedBox(
      width: Get.width,
      child: ListTile(
        onTap: openReverseCallDialog,
        dense: true,
        minLeadingWidth: 54.0,
        leading: CustomProfilePicture(
          name: user.user?.name ?? "A",
          avatarURL: user.user?.avatar,
          backgroundColor: Get.theme.primaryColor,
        ),
        title: Text(
          "${user.user?.name?.trim()} ",
          style: const TextStyle(fontWeight: Weight.heavy, fontSize: 16.0),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        subtitle: Visibility(
          visible:
              Get.find<UserConversionController>().conversionStatus.value ==
              ConversionStatus.Pending,
          replacement: const Text(
            "Converted",
            style: TextStyle(fontSize: FontSize.M, color: Color(0xFF4AA611)),
          ),
          child: Text(
            "$getCutoffMinutes remaining",
            style: const TextStyle(
              fontSize: FontSize.M,
              color: Color(0xFF4AA611),
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (Get.isRegistered<ChatOverviewController>()) {
                  Get.find<ChatOverviewController>()
                      .navigateToChatScreenUsingAccountId(
                        peerAccountId: user.accountId ?? 0,
                        isNew: false,
                        screenName: screenName,
                      );
                }
              },
              child: SizedBox(
                width: 30.0,
                height: 30.0,
                child: SvgPicture.asset(
                  AssetConstants.chat,
                  colorFilter: ColorFilter.mode(
                    Get.theme.primaryColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6.0),
            Container(
              width: 60.0,
              height: 30.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Get.theme.primaryColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.liveCall.tr,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 4.0),
                  Icon(Icons.call_rounded, color: Colors.white, size: 16.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
