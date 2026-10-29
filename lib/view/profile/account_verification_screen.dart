import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/account/get_kyc_response.dart';
import 'package:voiceclub_partner/view/profile/view_agreement_screen.dart';
import 'package:voiceclub_partner/view/profile/widgets/info_tile.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class AccountVerificationScreen extends StatelessWidget {
  final int userId;
  final GetKYCResponseModel kycResponseModel;
  final String phone;

  const AccountVerificationScreen({
    super.key,
    required this.userId,
    required this.kycResponseModel,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: LocaleKeys.accountVerification.tr),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Agreement",
                style: TextStyle(
                  fontWeight: Weight.heavy,
                  fontSize: FontSize.xL,
                ),
              ),
              InkWell(
                onTap: () {
                  if (kycResponseModel.signedDocumentPath?.isNotEmpty ??
                      false) {
                    Get.to(
                      () => ViewAgreementScreen(
                        fileName: kycResponseModel.signedDocumentPath ?? "",
                      ),
                    );
                  }
                },
                child: InfoTile(
                  title: LocaleKeys.liveSignedAgreement.tr,
                  trailing: Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const Text(
                "Account Details",
                style: TextStyle(
                  fontWeight: Weight.heavy,
                  fontSize: FontSize.xL,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                "PAN Number",
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.5),
                  fontWeight: Weight.heavy,
                ),
              ),
              InfoTile(title: kycResponseModel.pan ?? ""),
              Text(
                "Bank Details",
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.5),
                  fontWeight: Weight.heavy,
                ),
              ),
              InfoTile(
                title: kycResponseModel.accountNumber?.obfuscateString ?? "",
                subtitle: LocaleKeys.liveAccountNumber.tr,
              ),
              InfoTile(
                title: kycResponseModel.ifsc?.obfuscateString ?? "",
                subtitle: LocaleKeys.liveIfscCode.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
