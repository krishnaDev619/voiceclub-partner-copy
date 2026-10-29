// import 'dart:io';
// import 'dart:math';

// import 'package:flutter/services.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:loader_overlay/loader_overlay.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:voiceclub_partner/core/constants/asset_constants.dart';
// import 'package:voiceclub_partner/core/constants/enums.dart';
// import 'package:voiceclub_partner/core/injection_container.dart';
// import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
// import 'package:voiceclub_partner/core/services/alert_service.dart';
// import 'package:voiceclub_partner/core/services/analytics_service.dart';
// import 'package:voiceclub_partner/core/services/location_service.dart';
// import 'package:voiceclub_partner/core/services/logger.dart';
// import 'package:voiceclub_partner/data/models/account/get_kyc_response.dart';
// import 'package:voiceclub_partner/domain/usecases/account/get_kyc.dart';
// import 'package:voiceclub_partner/domain/usecases/account/get_onboarding_selfie.dart';
// import 'package:voiceclub_partner/domain/usecases/agreement/get_file_url.dart';
// import 'package:voiceclub_partner/domain/usecases/agreement/update_sign_document.dart'
//     as update_sign_document;
// import 'package:voiceclub_partner/domain/usecases/kyc_file/upload_kyc_file.dart';
// import 'package:voiceclub_partner/modules/controller/user_controller.dart';

// class AgreementController extends GetxController {
//   final isLoading = true.obs;
//   final isSigned = false.obs;
//   final kycResponse = GetKYCResponseModel().obs;
//   final pdfFile = File("").obs;
//   final _pdfDocument = PdfDocument().obs;

//   @override
//   void onInit() {
//     fetchData();
//     super.onInit();
//   }

//   /// ==========================================
//   /// API Calls
//   /// ==========================================
//   void fetchData() async {
//     await fetchKYCDetails();
//   }

//   Future<void> fetchKYCDetails() async {
//     try {
//       final response = await sl<GetKYCUsecase>().call(NoParams());
//       if (response.data != null && response.error == null) {
//         kycResponse.value = response.data ?? GetKYCResponseModel();
//         _loadPdf();
//       }
//     } catch (_) {
//       AlertService.showSnackBar(
//         snackBarType: SnackBarType.Warning,
//         title: "Something went wrong!",
//         subtitle: "Please try again later.",
//       );
//     } finally {}
//   }

//   Future<File?> getSelfieImageFile() async {
//     try {
//       final response = await sl<GetOnboardingSelfieUsecase>().call(NoParams());
//       if (response.data?.url?.isNotEmpty ?? false) {
//         String fileUrl = response.data?.url ?? "";
//         File file = await DefaultCacheManager().getSingleFile(fileUrl);
//         return file;
//       }
//     } catch (e) {
//       Logger.logMessage("Error in getSelfieImageFile ${e.toString()}");
//     }
//     return null;
//   }

//   Future<File?> getSignedDocumentFile(String fileName) async {
//     try {
//       var getFileUseCase = sl<GetFileUrlUseCase>();
//       var response = await getFileUseCase.call(
//         GetFileUrlParams(fileName: fileName),
//       );
//       if (response.data != null && response.error == null) {
//         String fileUrl = response.data?.url ?? "";
//         File file = await DefaultCacheManager().getSingleFile(fileUrl);
//         return file;
//       }
//     } catch (e) {
//       Logger.logMessage("Error in getSignedDocumentFile ${e.toString()}");
//     } finally {}
//     return null;
//   }

//   Future<void> uploadPDFFile(File pdfFile) async {
//     try {
//       final response = await sl<UploadKYCFileUsecase>().call(
//         Params(file: pdfFile, extension: "pdf"),
//       );
//       if (response.data != null) {
//         updateSignDocument(response.data?.file ?? "");
//       }
//     } catch (e) {
//       Logger.logMessage("Error in uploadPDFFile ${e.toString()}");
//     } finally {}
//   }

//   Future<void> updateSignDocument(String documentPath) async {
//     try {
//       final phoneNumber =
//           Get.find<UserController>().userDetails.value.user?.phoneNumber ?? "";
//       final updateSignDocumentUseCase =
//           sl<update_sign_document.UpdateSignDocument>();
//       var response = await updateSignDocumentUseCase.call(
//         update_sign_document.Params(
//           documentPath: documentPath,
//           phoneNumber: phoneNumber,
//         ),
//       );
//       if (response.data != null && response.error == null) {
//         Get.back();
//       }
//     } catch (e) {
//       Logger.logMessage("Error in updateSignDocument ${e.toString()}");
//     } finally {}
//   }

//   /// ==========================================
//   /// Agreement Functions
//   /// ==========================================

//   void _loadPdf() async {
//     try {
//       Uint8List pdfData = Uint8List(1);
//       if (kycResponse.value.signedDocumentPath?.isNotEmpty ?? false) {
//         // Load the PDF from network
//         var file = await getSignedDocumentFile(
//           kycResponse.value.signedDocumentPath ?? "",
//         );
//         if (file != null) {
//           pdfData = file.readAsBytesSync();
//           isSigned(false);
//         }
//       } else {
//         // Load the PDF from assets
//         final ByteData bytes = await rootBundle.load(
//           AssetConstants.emptyPdfFile,
//         );
//         pdfData = bytes.buffer.asUint8List();
//       }
//       _pdfDocument.value = PdfDocument(inputBytes: pdfData);
//       final outputDir = await getApplicationDocumentsDirectory();
//       final outputFile = File('${outputDir.path}/unsigned_document.pdf');
//       var file = await outputFile.writeAsBytes(_pdfDocument.value.saveSync());

//       pdfFile(file);
//       isLoading(false);
//     } catch (e) {
//       Logger.logMessage("Error in  _loadPdf ${e.toString()}");
//     }
//   }

//   Future<void> processSignature({required Uint8List signatureImageData}) async {
//     try {
//       Get.context?.loaderOverlay.show();
//       final partnerName = kycResponse.value.bankName ?? "";
//       final panNumber = kycResponse.value.pan ?? "";
//       final panPhoto = kycResponse.value.panPhoto ?? "";
//       final selfiePhoto = kycResponse.value.selfieImagePath ?? "";
//       final latlong = await LocationService().fetchLatLong();

//       // Add user info in pdf
//       await _addUserInfoToPdf(
//         name: partnerName,
//         panImage: panPhoto,
//         panNumber: panNumber,
//         selfieImage: selfiePhoto,
//         signatureImageData: signatureImageData,
//         latlong: latlong,
//       );

//       // Save the updated PDF
//       final outputDir = await getApplicationDocumentsDirectory();
//       final outputFile = File('${outputDir.path}/signed_document.pdf');
//       final file = await outputFile.writeAsBytes(_pdfDocument.value.saveSync());

//       await uploadPDFFile(file);

//       pdfFile(file);
//       isSigned(true);

//       // _pdfViewerController.jumpToPage(_pdfDocument.pages.count - 1);
//       sl<AnalyticsService>().trackEvent("signAgreementSuccessful");
//     } catch (e) {
//       Logger.logMessage("Error in processSignature ${e.toString()}");
//     } finally {
//       Get.context?.loaderOverlay.hide();
//     }
//   }

//   void _addImageBytesToPdf({
//     required Uint8List imageData,
//     required int pageIndex,
//     required double left,
//     required double top,
//     required double width,
//     required double height,
//   }) {
//     try {
//       final PdfPage page = _pdfDocument.value.pages[pageIndex];

//       final PdfBitmap signatureBitmap = PdfBitmap(imageData);

//       page.graphics.drawImage(
//         signatureBitmap,
//         Rect.fromLTWH(left, top, width, height),
//       );
//     } catch (e) {
//       Logger.logMessage("Error in _addSignatureToPdf ${e.toString()}");
//     }
//   }

//   void _addStringToPDF({
//     required String str,
//     required int pageIndex,
//     required double left,
//     required double top,
//     required double width,
//     required double height,
//   }) {
//     try {
//       final PdfPage page = _pdfDocument.value.pages[pageIndex];

//       //Draw the text
//       page.graphics.drawString(
//         str.trim(),
//         PdfStandardFont(PdfFontFamily.timesRoman, 10, style: PdfFontStyle.bold),
//         bounds: Rect.fromLTWH(left, top, width, height),
//       );
//     } catch (e) {
//       Logger.logMessage("Error in _addStringToPDF ${e.toString()}");
//     }
//   }

//   Future<void> _addUserInfoToPdf({
//     required String name,
//     required String panNumber,
//     required String selfieImage,
//     required String panImage,
//     required Uint8List signatureImageData,
//     required String latlong,
//   }) async {
//     try {
//       final date = DateFormat("dd/MM/yyyy").format(DateTime.now());
//       // ==========================================
//       // Name
//       // ==========================================

//       // Freelancer Name :
//       _addStringToPDF(
//         str: name,
//         pageIndex: 0,
//         left: 180.0,
//         top: 140.0,
//         width: 150,
//         height: 60,
//       );

//       // Dear :
//       _addStringToPDF(
//         str: name,
//         pageIndex: 0,
//         left: 110.0,
//         top: 186.0,
//         width: 150,
//         height: 60,
//       );

//       // On behalf of Partner
//       _addStringToPDF(
//         str: name,
//         pageIndex: _pdfDocument.value.pages.count - 1,
//         left: 364.0,
//         top: 310.0,
//         width: 150,
//         height: 60,
//       );

//       // ==========================================
//       // Date
//       // ==========================================

//       // Date
//       _addStringToPDF(
//         str: date,
//         pageIndex: _pdfDocument.value.pages.count - 1,
//         left: 350.0,
//         top: 406.0,
//         width: 150,
//         height: 60,
//       );

//       // Appointment :
//       _addStringToPDF(
//         str: date,
//         pageIndex: 0,
//         left: 150.0,
//         top: 388.0,
//         width: 150,
//         height: 60,
//       );

//       // ==========================================
//       // Place
//       // ==========================================

//       // Place
//       _addStringToPDF(
//         str: latlong,
//         pageIndex: _pdfDocument.value.pages.count - 1,
//         left: 350.0,
//         top: 422.0,
//         width: 150,
//         height: 60,
//       );

//       // ==========================================
//       // Pan Number
//       // ==========================================

//       // Freelancer Name :
//       _addStringToPDF(
//         str: panNumber,
//         pageIndex: 0,
//         left: 230.0,
//         top: 156.0,
//         width: 150,
//         height: 60,
//       );

//       // ==========================================
//       // Images
//       // ==========================================

//       // Signature
//       _addImageBytesToPdf(
//         imageData: signatureImageData,
//         pageIndex: _pdfDocument.value.pages.count - 1,
//         left: 380,
//         top: 360,
//         width: 120,
//         height: 46,
//       );

//       // Pan Card
//       await _addImageToPDF(
//         fileName: panImage,
//         pageIndex: _pdfDocument.value.pages.count - 1,
//         left: 90.0,
//         top: 590.0,
//         height: 120,
//         width: 200,
//       );

//       // Selfie
//       await _addImageToPDF(
//         fileName: selfieImage,
//         pageIndex: _pdfDocument.value.pages.count - 1,
//         left: 390.0,
//         top: 620.0,
//         height: 90.0,
//         width: 90.0,
//         isSelfie: true,
//       );
//     } catch (e) {
//       Logger.logMessage("Error in _addNameAndAddressToPdf ${e.toString()}");
//     }
//   }

//   Future<void> _addImageToPDF({
//     required String fileName,
//     required int pageIndex,
//     required double left,
//     required double top,
//     required double width,
//     required double height,
//     bool isSelfie = false,
//   }) async {
//     try {
//       final PdfPage page = _pdfDocument.value.pages[pageIndex];
//       File? file;
//       // Download the image from the URL
//       if (isSelfie) {
//         file = await getSelfieImageFile();
//       } else {
//         file = await getSignedDocumentFile(fileName);
//       }

//       if (file != null) {
//         // Convert to PdfBitmap
//         PdfBitmap image = PdfBitmap(file.readAsBytesSync());

//         // Draw the image on the PDF page
//         page.graphics.drawImage(image, Rect.fromLTWH(left, top, width, height));
//       } else {
//         Logger.logMessage("Failed to download image from URL: $fileName");
//       }
//     } catch (e) {
//       Logger.logMessage("Error in _addImageToPDF: ${e.toString()}");
//     }
//   }

//   Future<void> downloadPDF() async {
//     try {
//       const downloadsFolderPath = '/storage/emulated/0/Download';
//       Directory dir = Directory(downloadsFolderPath);
//       final file = File(
//         '${dir.path}/voiceclub_agreement${Random().nextInt(100)}.pdf',
//       );
//       Uint8List byteData = Uint8List(0);
//       if (pdfFile.value.path.isNotEmpty) {
//         byteData = pdfFile.value.readAsBytesSync();
//       }
//       await file.writeAsBytes(byteData);
//       AlertService.showSnackBar(
//         snackBarType: SnackBarType.Success,
//         title: "Downloaded Successfully",
//         subtitle: "Your agreement has been saved to files.",
//       );
//     } catch (e) {
//       Logger.logMessage("Error while downloading agreement ${e.toString()}");
//       AlertService.showSnackBar(
//         snackBarType: SnackBarType.Success,
//         title: "Something went wrong",
//         subtitle: "Please try again",
//       );
//     }
//   }

//   void fetchLocation() {}
// }
