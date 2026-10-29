import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/features/onboarding/views/agreement/controllers/agreement_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final _controller = Get.find<AgreementController>();
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

  void _handleClearButtonPressed() {
    setState(() {
      signatureGlobalKey.currentState!.clear();
    });
  }

  void _handleSaveButtonPressed() async {
    try {
      final data = await signatureGlobalKey.currentState!.toImage(
        pixelRatio: 3.0,
      );
      final bytes = await data.toByteData(format: ui.ImageByteFormat.png);

      if (bytes == null) return;

      final Uint8List signatureImageData = bytes.buffer.asUint8List();

      _controller.processSignature(signatureImageData: signatureImageData);
    } catch (e) {
      Logger.logError("Error in _handleSaveButtonPressed ${e.toString()}");
    }
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
          LocaleKeys.signOfferLetter.tr,
          style: TextStyle(fontWeight: Weight.heavy, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 16.0,
                  ),
                  child: Image.asset(AssetConstants.signContract),
                ),
              ),
              const SizedBox(height: 30.0),
              Expanded(
                flex: 2,
                child: Container(
                  height: 200.0,
                  width: MediaQuery.of(context).size.width - 20.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: SfSignaturePad(
                          key: signatureGlobalKey,
                          backgroundColor: const Color(0xFFF3F3F3),
                          strokeColor: Colors.black,
                          minimumStrokeWidth: 1.0,
                          maximumStrokeWidth: 4.0,
                          onDraw: (offset, time) {
                            setState(() {});
                          },
                        ),
                      ),
                      Visibility(
                        visible:
                            (signatureGlobalKey.currentState?.toPathList() ??
                                    [])
                                .isEmpty,
                        child: IgnorePointer(
                          child: Text(
                            LocaleKeys.signHere.tr,
                            style: TextStyle(
                              color: Color(0xFF939090),
                              fontWeight: FontWeight.w500,
                              fontSize: FontSize.xXXL,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Spacer(),
              Visibility(
                visible:
                    (signatureGlobalKey.currentState?.toPathList() ?? [])
                        .isNotEmpty,
                replacement: SizedBox(height: 54.0),
                child: SizedBox(
                  height: 54.0,
                  child: CustomButton(
                    onTap: _handleClearButtonPressed,
                    filled: false,
                    text: LocaleKeys.clear.tr,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              SizedBox(
                height: 54.0,
                child: CustomButton(
                  enabled:
                      (signatureGlobalKey.currentState?.toPathList() ?? [])
                          .isNotEmpty,
                  onTap: _handleSaveButtonPressed,
                  text: LocaleKeys.continueLabel.tr,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
