// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import 'package:voiceclub_partner/core/constants/asset_constants.dart';
// import 'package:voiceclub_partner/core/constants/ui_constants.dart';
// import 'package:voiceclub_partner/core/injection_container.dart';
// import 'package:voiceclub_partner/core/services/analytics_service.dart';
// import 'package:voiceclub_partner/view/onboarding/controller/agreement_controller.dart';
// import 'package:voiceclub_partner/view/onboarding/signature_screen.dart';
// import 'package:voiceclub_partner/view/widgets/custom_button.dart';

// class SignAgreementScreen extends StatefulWidget {
//   const SignAgreementScreen({super.key});

//   @override
//   State<SignAgreementScreen> createState() => _SignAgreementScreenState();
// }

// class _SignAgreementScreenState extends State<SignAgreementScreen> {
//   final _agreementController = Get.find<AgreementController>();
//   final PdfViewerController _pdfViewerController = PdfViewerController();

//   @override
//   void initState() {
//     sl<AnalyticsService>().trackEvent("signAgreement");
//     checkLocationPermission();
//     super.initState();
//   }

//   Future<void> checkLocationPermission() async {
//     final permission = await Permission.location.request();
//     if (!permission.isGranted) {
//       Permission.location.request();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (_agreementController.isLoading.value) {
//         return const Center(child: CircularProgressIndicator());
//       }
//       return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0.0,
//           centerTitle: true,
//           leading: IconButton(
//             onPressed: () {
//               Get.back();
//             },
//             icon: const Icon(Icons.arrow_back_ios),
//           ),
//           title: Visibility(
//             visible: !_agreementController.isSigned.value,
//             child: const Text(
//               "Agreement",
//               style: TextStyle(fontWeight: Weight.heavy, color: Colors.black),
//             ),
//           ),
//           actions: [
//             Visibility(
//               visible: _agreementController.isSigned.value,
//               child: GestureDetector(
//                 onTap: _agreementController.downloadPDF,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8.0),
//                     color: Get.theme.primaryColor,
//                   ),
//                   margin: const EdgeInsets.all(8.0),
//                   padding: const EdgeInsets.all(10.0),
//                   child: Row(
//                     children: [
//                       SvgPicture.asset(AssetConstants.downloading),
//                       const SizedBox(width: 8.0),
//                       const Text(
//                         "Download PDF",
//                         style: TextStyle(fontWeight: Weight.heavy),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         body: SafeArea(
//           child: Column(
//             children: [
//               Expanded(
//                 child: SfPdfViewer.file(
//                   _agreementController.pdfFile.value,
//                   controller: _pdfViewerController,
//                 ),
//               ),
//               const SizedBox(height: 10.0),
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16.0,
//                   vertical: 8.0,
//                 ),
//                 child: CustomButton(
//                   text: "Continue",
//                   onTap: () {
//                     if (_agreementController.isSigned.value) {
//                       Get.back();
//                       sl<AnalyticsService>().trackEvent(
//                         "signAgreementContinue",
//                       );
//                     } else {
//                       Get.to(() => const SignatureScreen());
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }
