import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/domain/usecases/account/get_kyc.dart';
import 'package:voiceclub_partner/view/profile/account_verification_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CustomTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final void Function()? onTap;
  final Widget? trailing;

  const CustomTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.shade100,
        ),
        child: Icon(icon, color: Colors.black),
      ),
      dense: true,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      subtitle:
          subtitle == null
              ? null
              : Text(subtitle!, style: const TextStyle(fontSize: 12)),
      trailing:
          trailing ??
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black),
    );
  }
}

class VerificationTile extends StatelessWidget {
  final bool isVerified;
  final int userId;
  final String phone;

  const VerificationTile({
    super.key,
    required this.isVerified,
    required this.userId,
    required this.phone,
  });

  void fetchKYCDetails() async {
    try {
      Get.context?.loaderOverlay.show();
      final response = await sl<GetKYCUsecase>().call(NoParams());
      if (response.data != null && response.error == null) {
        Get.context?.loaderOverlay.hide();
        Get.to(
          () => AccountVerificationScreen(
            kycResponseModel: response.data!,
            userId: userId,
            phone: phone,
          ),
        );
      }
    } catch (_) {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Warning,
        title: LocaleKeys.liveSomethingWentWrong.tr,
        subtitle: LocaleKeys.pleaseTryAgainLater.tr,
      );
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        sl<AnalyticsService>().trackEvent(
          "partnerVerification",
          eventProperties: {"isVerified": isVerified},
        );
        if (isVerified) {
          fetchKYCDetails();
        }
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.shade100,
        ),
        child: const Icon(Icons.person, color: Colors.black),
      ),
      dense: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(
            child: Text(
              "Account Verification",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: isVerified ? Colors.green : Colors.red,
            ),
            child: Text(
              isVerified ? "Verified" : "Pending",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: FontSize.M,
              ),
            ),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.black,
      ),
    );
  }
}
