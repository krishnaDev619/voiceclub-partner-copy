import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/domain/usecases/feature/mark_whatsapp_group_as_seen.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class JoinWhatsAppGroupBottomSheet extends StatelessWidget {
  const JoinWhatsAppGroupBottomSheet({super.key});

  Future<void> handleJoinGroup() async {
    try {
      HapticFeedback.vibrate();
      final language =
          Get.find<UserController>().userDetails.value.primaryLanguage
              ?.trim()
              .toLowerCase();

      // Disable for Telugu
      if (language == 'telugu') {
        Get.back();
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.homeNotAvailable.tr,
          subtitle: LocaleKeys.homeWhatsappTelugu.tr,
        );
        return;
      }

      // Determine which group to join based on language
      final groupLink =
          language == 'tamil'
              ? URLConstants.homeWhatsappTamilGroupLink
              : URLConstants.homeWhatsappHindiGroupLink;

      // Launch WhatsApp group link
      final uri = Uri.parse(groupLink);
      if (await canLaunchUrl(uri)) {
        Get.back();
        // Mark the WhatsApp group as seen
        final accountId =
            Get.find<UserController>().userDetails.value.accountId.toString();
        await sl<MarkWhatsAppGroupAsSeenUseCase>().call(
          MarkWhatsAppGroupAsSeenParams(accountId: accountId),
        );
        await launchUrl(uri);
        sl<AnalyticsService>().trackEvent(
          "joinWhatsAppGroup",
          eventProperties: {"language": language, "groupLink": groupLink},
        );
      } else {
        Get.back();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: Get.height * 0.5,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.homeWhatsappTitle.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: FontSize.xXL,
              ),
            ),
            SizedBox(
              height: Get.height * 0.3,
              width: Get.width * 0.8,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Image.asset(
                  AssetConstants.joinWhatsapp,
                  width: Get.width * 0.8,
                  height: Get.height * 0.3,
                ),
              ),
            ),
            CustomButton(
              text: LocaleKeys.homeJoinGroup.tr,
              color: Colors.green,
              onTap: handleJoinGroup,
            ),
          ],
        ),
      ),
    );
  }
}
