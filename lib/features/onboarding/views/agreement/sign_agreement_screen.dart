import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/views/agreement/signature_screen.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class SignAgreementScreen extends StatefulWidget {
  const SignAgreementScreen({super.key});

  @override
  State<SignAgreementScreen> createState() => _SignAgreementScreenState();
}

class _SignAgreementScreenState extends State<SignAgreementScreen> {
  @override
  void initState() {
    sl<AnalyticsService>().trackEvent("signAgreementScreen");
    _showAndHideLoader();
    checkLocationPermission();
    super.initState();
  }

  Future<void> checkLocationPermission() async {
    final permission = await Permission.location.request();
    if (!permission.isGranted) {
      await Permission.location.request();
    }
    sl<AnalyticsService>().trackEvent(
      "permissionPopup",
      eventProperties: {
        "permission": permission.name,
        "type": "Location",
        "screenName": "signAgreementScreen",
      },
    );
  }

  void _showAndHideLoader() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.context?.loaderOverlay.show();
        Future.delayed(const Duration(seconds: 5), () {
          Get.context?.loaderOverlay.hide();
        });
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          LocaleKeys.offerLetter.tr,
          style: TextStyle(fontWeight: Weight.heavy, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SfPdfViewer.asset(
                key: UniqueKey(),
                AssetConstants.emptyPdfFile,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: CustomButton(
                text: LocaleKeys.continueLabel.tr,
                onTap: () {
                  Get.to(() => const SignatureScreen());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
