import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/calling/get_reverse_calling_stats_reponse.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/view/chat/widgets/outgoing_call_dialog.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ReverseCallSection extends StatefulWidget {
  final ChatTheme theme;
  final ChatMember peerData;
  final int chatGroupId;
  final ChatTabFilter filter;
  final GetReverseCallingStatsResponseModel reverseCallingStatsResponse;

  const ReverseCallSection({
    super.key,
    required this.theme,
    required this.peerData,
    required this.chatGroupId,
    required this.filter,
    required this.reverseCallingStatsResponse,
  });

  @override
  State<ReverseCallSection> createState() => _ReverseCallSectionState();
}

class _ReverseCallSectionState extends State<ReverseCallSection> {
  @override
  Widget build(BuildContext context) {
    final remainingDuration =
        ((widget.reverseCallingStatsResponse.rechargedDuration ?? 0) / 60)
            .toInt();
    sl<AnalyticsService>().trackEvent(
      "chatScreenReverseCallSectionPartner",
      eventProperties: {
        'isEligible': widget.reverseCallingStatsResponse.isCallAllowed,
        'hasPassedCriteria':
            widget.reverseCallingStatsResponse.hasPassedCriteria,
        'remainingDuration':
            widget.reverseCallingStatsResponse.rechargedDuration,
        'peerName': widget.peerData.user?.name,
        'peerAccountId': widget.peerData.accountId,
      },
    );
    return InkWell(
      onTap: _showReverseCallPlansBottomSheet,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(16.0),
            bottomLeft: Radius.circular(16.0),
          ),
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible: !widget.reverseCallingStatsResponse.hasRecharged,
              child: Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 16.0,
                  backgroundColor: widget.theme.primaryColor,
                  child: SvgPicture.asset(AssetConstants.phoneOutgoing),
                ),
              ),
            ),
            Expanded(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                text: TextSpan(
                  style: TextStyle(
                    fontWeight: Weight.heavy,
                    fontSize: FontSize.xL,
                    color: Colors.black,
                    height: 1.5,
                  ),
                  children:
                      !widget.reverseCallingStatsResponse.hasPassedCriteria
                          ? [
                            TextSpan(
                              text: LocaleKeys.liveTalkToNameFor.trParams({
                                'name': widget.peerData.user?.name ?? '',
                              }),
                            ),
                            TextSpan(
                              text:
                                  widget
                                      .reverseCallingStatsResponse
                                      .remainingDurationString,
                              style: TextStyle(
                                color: widget.theme.primaryColor,
                                fontWeight: Weight.heavy,
                                fontSize: FontSize.xL,
                              ),
                            ),
                            TextSpan(
                              text: LocaleKeys.liveToUnlockReverseCall.tr,
                            ),
                          ]
                          : widget.reverseCallingStatsResponse.hasRecharged
                          ? [
                            TextSpan(
                              text: LocaleKeys.liveCallNameColon.trParams({
                                'name': widget.peerData.user?.name ?? '',
                              }),
                            ),
                            TextSpan(
                              text: LocaleKeys.liveMinsLeft.trParams({
                                'duration': '$remainingDuration',
                              }),
                              style: TextStyle(
                                color: widget.theme.primaryColor,
                                fontWeight: Weight.heavy,
                                fontSize: FontSize.xL,
                              ),
                            ),
                          ]
                          : [
                            TextSpan(
                              text: LocaleKeys.liveCallName.trParams({
                                'name': widget.peerData.user?.name ?? '',
                              }),
                            ),
                          ],
                ),
              ),
            ),
            Visibility(
              visible: widget.reverseCallingStatsResponse.hasPassedCriteria,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.theme.primaryColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 6.0,
                ),
                child: Row(
                  children: [
                    Icon(Icons.call_rounded, color: Colors.white, size: 20.0),
                    SizedBox(width: 4.0),
                    Text(
                      LocaleKeys.liveCallNow.tr,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReverseCallPlansBottomSheet() {
    HapticFeedback.vibrate();
    Get.dialog(
      OutgoingCallDialog(
        reverseCallingStatsResponse: widget.reverseCallingStatsResponse,
        demandPeer: widget.peerData,
        chatGroupId: widget.chatGroupId,
        screenName: "ChatScreen${widget.filter.name}",
      ),
    );
  }
}
