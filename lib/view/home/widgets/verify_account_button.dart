import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/core/services/hyperverge_service.dart';
import 'package:voiceclub_partner/data/models/data.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

enum VerificationType { verificationPending, kycPending }

class VerifyAccountButton extends StatelessWidget {
  const VerifyAccountButton({super.key});

  /// Determines which verification type should be shown based on user data
  /// Priority: Verification Pending > KYC Pending
  static VerificationType? _getVerificationType(DataModel userDetails) {
    // Check for Verification Pending first (higher priority)
    final isVerificationPending =
        userDetails.aadharSignEligible == true &&
        userDetails.aadharSignDone == false &&
        sl<GrowthBookService>().isFeatureEnabled(FeatureFlag.newkycflow);

    if (isVerificationPending) {
      return VerificationType.verificationPending;
    }

    // Check for KYC Pending
    final isKYCPending =
        userDetails.kycEligible == true && userDetails.kycCompleted == false;

    if (isKYCPending) {
      return VerificationType.kycPending;
    }

    return null;
  }

  /// Returns the title text based on verification type
  static String _getTitle(VerificationType type) {
    switch (type) {
      case VerificationType.verificationPending:
        return LocaleKeys.homeVerificationPending.tr;
      case VerificationType.kycPending:
        return LocaleKeys.homeKycPending.tr;
    }
  }

  /// Returns the subtitle text based on verification type
  static String _getSubtitle(VerificationType type) {
    switch (type) {
      case VerificationType.verificationPending:
        return LocaleKeys.homeCompleteVerification.tr;
      case VerificationType.kycPending:
        return LocaleKeys.homeCompletePayouts.tr;
    }
  }

  /// Handles the tap action based on verification type
  static Future<void> _handleVerificationTap(
    VerificationType type,
    String phoneNumber,
  ) async {
    switch (type) {
      case VerificationType.verificationPending:
        await HypervergeKYCService.launchAadharSign(phone: phoneNumber);
        break;
      case VerificationType.kycPending:
        await HypervergeKYCService.launch(phoneNumber: phoneNumber);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return Obx(() {
      final userDetails = userController.userDetails.value;
      final verificationType = _getVerificationType(userDetails);

      // Hide banner if no verification is pending
      if (verificationType == null) {
        return const SizedBox.shrink();
      }

      final phoneNumber = userDetails.user?.phoneNumber ?? '';

      return Container(
        margin: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 20.0,
          bottom: 10.0,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: ApplicationColors.errorColor,
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white, size: 24.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getTitle(verificationType),
                    style: const TextStyle(
                      fontSize: FontSize.xL,
                      fontWeight: Weight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    _getSubtitle(verificationType),
                    style: TextStyle(
                      fontSize: FontSize.M,
                      fontWeight: Weight.normal,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            GestureDetector(
              onTap:
                  () => _handleVerificationTap(verificationType, phoneNumber),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Colors.white,
                ),
                child: Text(
                  LocaleKeys.homeStartNow.tr,
                  style: TextStyle(
                    fontSize: FontSize.L,
                    fontWeight: Weight.bold,
                    color: ApplicationColors.primaryRed,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
