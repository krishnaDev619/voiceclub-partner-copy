import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/views/post_onboarding/congratulations_screen.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class ViewSignedAgreementScreen extends StatefulWidget {
  final String signedDocumentUrl;
  const ViewSignedAgreementScreen({super.key, required this.signedDocumentUrl});

  @override
  State<ViewSignedAgreementScreen> createState() =>
      _ViewSignedAgreementScreenState();
}

class _ViewSignedAgreementScreenState extends State<ViewSignedAgreementScreen> {
  @override
  void initState() {
    sl<AnalyticsService>().trackEvent("viewSignedAgreementScreen");
    _showAndHideLoader();
    super.initState();
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

  void downloadSignedAgreement() async {
    try {
      final file = await FileDownloader.downloadFile(
        url: widget.signedDocumentUrl,
        name:
            'voiceclub_agreement_${DateTime.now().millisecondsSinceEpoch}.pdf',
        downloadDestination: DownloadDestinations.publicDownloads,
      );

      if (file == null) {
        throw Exception('Failed to download file');
      }
      AlertService.showSnackBar(
        title: LocaleKeys.downloadedSuccessfully.tr,
        subtitle: LocaleKeys.agreementSaved.tr,
        snackBarType: SnackBarType.Success,
      );
    } catch (e) {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.somethingWentWrong.tr,
        subtitle: LocaleKeys.pleaseTryAgain.tr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            LocaleKeys.signedOfferLetter.tr,
            style: TextStyle(fontWeight: Weight.heavy, color: Colors.black),
          ),
          actions: [
            GestureDetector(
              onTap: downloadSignedAgreement,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 0.0,
                ),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.downloading_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Text(
                      LocaleKeys.downloadPdf.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: FontSize.S,
                        fontWeight: Weight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SfPdfViewer.network(
                  key: UniqueKey(),
                  widget.signedDocumentUrl,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: CustomButton(
                  text: LocaleKeys.completeOnboarding.tr,
                  onTap: () {
                    Get.offAll(() => CongratulationsScreen());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
