import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/helper_functions.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/location_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/update_data/get_file_url.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/update_data/update_sign_document.dart';
import 'package:voiceclub_partner/features/onboarding/domain/usecases/upload_file/upload_onboarding_file.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/auth_controller.dart';
import 'package:voiceclub_partner/features/onboarding/views/agreement/view_signed_agreement_screen.dart';

class AgreementController extends GetxController {
  final _pdfDocument = PdfDocument().obs;

  /// ==========================================
  /// API Calls
  /// ==========================================

  Future<String?> _getFileUrl(String fileName) async {
    try {
      final response = await sl<GetFileUrlUseCase>().call(
        GetFileUrlParams(fileName: fileName),
      );
      if (response.data != null && response.error == null) {
        String fileUrl = response.data?.url ?? "";
        return fileUrl;
      }
    } catch (e) {
      Logger.logError("Error in getSignedDocumentFile ${e.toString()}");
    } finally {}
    return null;
  }

  Future<void> _uploadPDFFile(File file) async {
    try {
      final response = await sl<UploadOnboardingFileUsecase>().call(
        UploadOnboardingFileParams(file: file),
      );
      if (response.data?.file?.isNotEmpty == true) {
        await _updateSignDocument(response.data?.file ?? "");
      } else {
        _showErrorSnackBar(
          title: LocaleKeys.couldNotUploadPdf.tr,
          subtitle: LocaleKeys.pleaseTryAgainLater.tr,
        );
      }
    } catch (e) {
      Logger.logError("Error in uploadPDFFile ${e.toString()}");
    }
  }

  Future<void> _updateSignDocument(String documentPath) async {
    try {
      final phoneNumber =
          Get.find<AuthController>().profileResponseModel.value.phone ?? "";
      final response = await sl<UpdateSignDocument>().call(
        UpdateSignDocumentParams(
          documentPath: documentPath,
          phoneNumber: phoneNumber,
        ),
      );
      if (response.data != null && response.error == null) {
        sl<AnalyticsService>().trackEvent("signAgreementSuccessful");
        await _completeOnboarding(documentPath);
      } else {
        _showErrorSnackBar(
          title: LocaleKeys.couldNotUpdateSignDocument.tr,
          subtitle: LocaleKeys.pleaseTryAgainLater.tr,
        );
      }
    } catch (e) {
      Logger.logError("Error in updateSignDocument ${e.toString()}");
    }
  }

  Future<void> _completeOnboarding(String signedDocumentPath) async {
    try {
      final authController = Get.find<AuthController>();
      final isSuccess = await authController.completeOnboarding(
        signedDocumentPath,
      );

      if (isSuccess) {
        final signedDocumentUrl = await _getFileUrl(signedDocumentPath);
        if (signedDocumentUrl?.isNotEmpty == true) {
          Get.context?.loaderOverlay.hide();
          Get.offAll(
            () => ViewSignedAgreementScreen(
              signedDocumentUrl: signedDocumentUrl ?? "",
            ),
          );
        } else {
          _showErrorSnackBar(
            title: LocaleKeys.couldNotShowSignedPdf.tr,
            subtitle: LocaleKeys.pleaseTryAgainLater.tr,
          );
        }
      } else {
        // Complete onboarding failed after all retries
        Get.context?.loaderOverlay.hide();
        authController.goToOnboardingFailureScreen(signedDocumentPath);
      }
    } catch (e) {
      Logger.logError("Error in _completeOnboarding ${e.toString()}");
      Get.context?.loaderOverlay.hide();
      Get.find<AuthController>().goToOnboardingFailureScreen(
        signedDocumentPath,
      );
    }
  }

  /// ==========================================
  /// Agreement Functions
  /// ==========================================

  Future<void> processSignature({required Uint8List signatureImageData}) async {
    try {
      Get.context?.loaderOverlay.show();
      final selfiePhoto =
          Get.find<AuthController>().profileResponseModel.value.imagePath ?? "";
      final latlong = await LocationService().fetchLatLong();
      final name =
          Get.find<AuthController>().profileResponseModel.value.name ?? "";

      // Load the PDF from assets
      final ByteData bytes = await rootBundle.load(AssetConstants.emptyPdfFile);
      final pdfData = bytes.buffer.asUint8List();
      _pdfDocument.value = PdfDocument(inputBytes: pdfData);

      // Add user info in pdf
      await _addUserInfoToPdf(
        name: name,
        selfieImage: selfiePhoto,
        signatureImageData: signatureImageData,
        latlong: latlong,
      );

      // Save the updated PDF
      final outputDir = await getApplicationDocumentsDirectory();
      final outputFile = File('${outputDir.path}/signed_document.pdf');
      final file = await outputFile.writeAsBytes(_pdfDocument.value.saveSync());
      await _uploadPDFFile(file);
    } catch (e) {
      Logger.logError("Error in processSignature ${e.toString()}");
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  void _addImageBytesToPdf({
    required Uint8List imageData,
    required int pageIndex,
    required double left,
    required double top,
    required double width,
    required double height,
  }) {
    try {
      final PdfPage page = _pdfDocument.value.pages[pageIndex];

      final PdfBitmap signatureBitmap = PdfBitmap(imageData);

      page.graphics.drawImage(
        signatureBitmap,
        Rect.fromLTWH(left, top, width, height),
      );
    } catch (e) {
      Logger.logError("Error in _addSignatureToPdf ${e.toString()}");
    }
  }

  void _addStringToPDF({
    required String str,
    required int pageIndex,
    required double left,
    required double top,
    required double width,
    required double height,
  }) {
    try {
      final PdfPage page = _pdfDocument.value.pages[pageIndex];

      //Draw the text
      page.graphics.drawString(
        str.trim(),
        PdfStandardFont(PdfFontFamily.timesRoman, 10, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(left, top, width, height),
      );
    } catch (e) {
      Logger.logError("Error in _addStringToPDF ${e.toString()}");
    }
  }

  Future<void> _addUserInfoToPdf({
    required String name,
    required String selfieImage,
    required Uint8List signatureImageData,
    required String latlong,
  }) async {
    try {
      final date = DateFormat("dd/MM/yyyy").format(DateTime.now());
      // ==========================================
      // Name
      // ==========================================

      // Freelancer Name :
      _addStringToPDF(
        str: name,
        pageIndex: 0,
        left: 180.0,
        top: 140.0,
        width: 150,
        height: 60,
      );

      // Dear :
      _addStringToPDF(
        str: name,
        pageIndex: 0,
        left: 110.0,
        top: 186.0,
        width: 150,
        height: 60,
      );

      // On behalf of Partner
      _addStringToPDF(
        str: name,
        pageIndex: _pdfDocument.value.pages.count - 1,
        left: 364.0,
        top: 310.0,
        width: 150,
        height: 60,
      );

      // ==========================================
      // Date
      // ==========================================

      // Date
      _addStringToPDF(
        str: date,
        pageIndex: _pdfDocument.value.pages.count - 1,
        left: 350.0,
        top: 406.0,
        width: 150,
        height: 60,
      );

      // Appointment :
      _addStringToPDF(
        str: date,
        pageIndex: 0,
        left: 150.0,
        top: 388.0,
        width: 150,
        height: 60,
      );

      // ==========================================
      // Place
      // ==========================================

      // Place
      _addStringToPDF(
        str: latlong,
        pageIndex: _pdfDocument.value.pages.count - 1,
        left: 350.0,
        top: 422.0,
        width: 150,
        height: 60,
      );

      // ==========================================
      // Images
      // ==========================================

      // Signature
      _addImageBytesToPdf(
        imageData: signatureImageData,
        pageIndex: _pdfDocument.value.pages.count - 1,
        left: 380,
        top: 360,
        width: 120,
        height: 46,
      );

      // Selfie
      await _addImageToPDF(
        fileName: selfieImage,
        pageIndex: _pdfDocument.value.pages.count - 1,
        left: 390.0,
        top: 620.0,
        height: 90.0,
        width: 90.0,
      );
    } catch (e) {
      Logger.logError("Error in _addNameAndAddressToPdf ${e.toString()}");
    }
  }

  Future<void> _addImageToPDF({
    required String fileName,
    required int pageIndex,
    required double left,
    required double top,
    required double width,
    required double height,
  }) async {
    try {
      final PdfPage page = _pdfDocument.value.pages[pageIndex];
      String? fileUrl;
      // Download the image from the URL
      fileUrl = await _getFileUrl(fileName);

      if (fileUrl != null) {
        // Convert to PdfBitmap
        final bytes = await HelperFunctions.fetchUrlAsBytes(fileUrl);
        PdfBitmap image = PdfBitmap(bytes);

        // Draw the image on the PDF page
        page.graphics.drawImage(image, Rect.fromLTWH(left, top, width, height));
      } else {
        Logger.logError("Failed to download image from URL: $fileName");
      }
    } catch (e) {
      Logger.logError("Error in _addImageToPDF: ${e.toString()}");
    }
  }

  void _showErrorSnackBar({required String? title, required String? subtitle}) {
    AlertService.showSnackBar(
      snackBarType: SnackBarType.Warning,
      title: title ?? LocaleKeys.somethingWentWrong.tr,
      subtitle: subtitle ?? LocaleKeys.pleaseTryAgainLater.tr,
    );
  }
}
