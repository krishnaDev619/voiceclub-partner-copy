import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/account/meeting.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class JoinMeetingBottomSheet extends StatelessWidget {
  final Meeting meeting;

  const JoinMeetingBottomSheet({super.key, required this.meeting});

  Future<void> _handleJoinMeeting() async {
    try {
      HapticFeedback.vibrate();

      final googleMeetLink = meeting.googleMeetLink;
      if (googleMeetLink == null || googleMeetLink.isEmpty) {
        Get.back();
        return;
      }

      final uri = Uri.parse(googleMeetLink);
      if (await canLaunchUrl(uri)) {
        Get.back();
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        sl<AnalyticsService>().trackEvent(
          "joinMeeting",
          eventProperties: {
            'meetingLink': googleMeetLink,
            'meetingId': meeting.id,
            'timing': meeting.formattedTimingString,
            'source': 'bottom_sheet',
          },
        );
      } else {
        Get.back();
      }
    } catch (_) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title
            Text(
              LocaleKeys.homeJoinMeetingTitle.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: FontSize.xXL,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 32.0),

            // Meeting Image
            Flexible(
              child: SizedBox(
                height: Get.height * 0.3,
                width: Get.width * 0.65,
                child: Image.asset(AssetConstants.meeting, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 32.0),

            // Join Meeting Button
            CustomButton(
              text: LocaleKeys.homeJoinMeetingNow.tr,
              color: const Color(0xFFEE6464),
              onTap: _handleJoinMeeting,
            ),
          ],
        ),
      ),
    );
  }
}
