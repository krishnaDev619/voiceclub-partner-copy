import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/domain/usecases/agreement/get_file_url.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ViewAgreementScreen extends StatefulWidget {
  final String fileName;

  const ViewAgreementScreen({super.key, required this.fileName});

  @override
  State<ViewAgreementScreen> createState() => _ViewAgreementScreenState();
}

class _ViewAgreementScreenState extends State<ViewAgreementScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  String pdfUrl = "";
  bool isLoading = true;

  @override
  void initState() {
    _loadPdf();
    super.initState();
  }

  Future<String?> getSignedDocumentFile(String fileName) async {
    try {
      var getFileUseCase = sl<GetFileUrlUseCase>();
      var response = await getFileUseCase.call(
        GetFileUrlParams(fileName: fileName),
      );
      if (response.data != null && response.error == null) {
        String fileUrl = response.data?.url ?? "";
        return fileUrl;
      }
    } catch (e) {
      // Logger.logError(e.toString());
    } finally {}
    return null;
  }

  void _loadPdf() async {
    // Load the PDF from network
    var url = await getSignedDocumentFile(widget.fileName);
    if (url != null) {
      pdfUrl = url;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text(
          "Agreement",
          style: TextStyle(fontWeight: Weight.heavy, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SfPdfViewer.network(pdfUrl, key: _pdfViewerKey),
            ),
            const SizedBox(height: 10.0),
            if (!isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: CustomButton(
                  text: LocaleKeys.continueLabel.tr,
                  onTap: () {
                    Get.back();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
