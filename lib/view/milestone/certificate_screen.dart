import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  Uint8List? _originalPdfBytes;
  Uint8List? _modifiedPdfBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      sl<AnalyticsService>().trackEvent("certificateScreen");
      // Load the original PDF from assets
      final ByteData data = await rootBundle.load(
        AssetConstants.payoutCertificate,
      );
      _originalPdfBytes = data.buffer.asUint8List();

      // Get user name and auto-generate the certificate
      final userController = Get.find<UserController>();
      final userName = userController.userDetails.value.user?.name ?? '';

      if (userName.isNotEmpty) {
        await _updateCertificate(userName);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error loading certificate: ${e.toString()}');
    }
  }

  Future<void> _updateCertificate(String name) async {
    if (name.trim().isEmpty) {
      return;
    }

    try {
      // Load the original PDF document
      final PdfDocument document = PdfDocument(inputBytes: _originalPdfBytes!);

      // Get the first page
      final PdfPage page = document.pages[0];

      // Create graphics for the page
      final PdfGraphics graphics = page.graphics;

      // Create a bold font for the name
      // Use appropriate font size for A4 landscape certificate
      final PdfFont font = PdfStandardFont(
        PdfFontFamily.timesRoman,
        32, // Larger font for landscape format with more horizontal space
        style: PdfFontStyle.bold,
      );

      final String userName = name.trim();

      // Measure the text to center it horizontally
      final Size textSize = font.measureString(userName);

      // Position name at exact coordinates: 271 x 380 from top-left
      final double nameX = 335.0; // X position from left edge
      final double nameY = 353.0; // Y position from top edge

      // Calculate text area width with some padding for the text bounds
      final double textAreaWidth = textSize.width + 20;

      // Draw the name with bold font at exact position
      graphics.drawString(
        userName,
        font,
        bounds: Rect.fromLTWH(
          nameX, // Start exactly at x=275
          nameY, // Start exactly at y=400
          textAreaWidth,
          textSize.height + 10, // Vertical padding for text bounds
        ),
        brush: PdfSolidBrush(PdfColor(0, 0, 0)), // Black color
        format: PdfStringFormat(
          alignment:
              PdfTextAlignment
                  .left, // Left align since we're positioning exactly
          lineAlignment: PdfVerticalAlignment.top,
        ),
      );

      // Save the modified document
      final savedBytes = await document.save();
      _modifiedPdfBytes = Uint8List.fromList(savedBytes);
      document.dispose();
    } catch (e) {
      _showErrorDialog('Error updating certificate: ${e.toString()}');
    }
  }

  Future<void> _downloadCertificate() async {
    if (_modifiedPdfBytes == null) {
      _showErrorDialog('Certificate is not ready yet');
      return;
    }

    try {
      sl<AnalyticsService>().trackEvent("downloadCertificate");
      // Get user name for file naming
      final userController = Get.find<UserController>();
      final userName =
          userController.userDetails.value.user?.name ?? 'Certificate';

      // Get the Downloads directory
      const downloadsFolderPath = '/storage/emulated/0/Download';
      Directory dir = Directory(downloadsFolderPath);
      final file = File(
        '${dir.path}/Partner_Certificate_${userName.trim().replaceAll(' ', '_')}_${Random().nextInt(1000)}.pdf',
      );

      // Write the PDF bytes to file
      await file.writeAsBytes(_modifiedPdfBytes!);

      // Show success message
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Success,
        title: LocaleKeys.downloadedSuccessfully.tr,
        subtitle: LocaleKeys.liveYourCertificateHasBeenSaved.tr,
      );

      sl<AnalyticsService>().trackEvent("certificateDownloaded");
    } catch (e) {
      _showErrorDialog('Error downloading certificate: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.errorTitle.tr),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(LocaleKeys.ok.tr),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Stack(
                  children: [
                    // PDF viewer section
                    Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white),
                            child:
                                _modifiedPdfBytes != null
                                    ? SfPdfViewer.memory(
                                      _modifiedPdfBytes!,
                                      controller: _pdfViewerController,
                                    )
                                    : _originalPdfBytes != null
                                    ? SfPdfViewer.memory(
                                      _originalPdfBytes!,
                                      controller: _pdfViewerController,
                                    )
                                    : const Center(
                                      child: Text(
                                        'Certificate not available',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.transparent,
                              ),
                            ),
                            Text(
                              'Best Listener',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Download button section
                    if (_modifiedPdfBytes != null)
                      Column(
                        children: [
                          Expanded(child: SizedBox()),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CustomButton(
                              text: LocaleKeys.liveDownload.tr,
                              onTap: _downloadCertificate,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
    );
  }
}
