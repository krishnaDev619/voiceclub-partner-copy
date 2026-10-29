import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/tutorial/demo_question_model.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/demo_audio_button_widget.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/home/demo_close_warning_dialog.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoQuestionWidget extends StatelessWidget {
  final DemoQuestionModel question;
  final int totalQuestions;
  final int currentQuestionIndex;
  final bool isTopView;

  const DemoQuestionWidget({
    super.key,
    required this.question,
    required this.totalQuestions,
    required this.currentQuestionIndex,
    this.isTopView = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFDD7A),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(isTopView ? 20 : 0),
            bottomRight: Radius.circular(isTopView ? 20 : 0),
            topLeft: Radius.circular(isTopView ? 0 : 20),
            topRight: Radius.circular(isTopView ? 0 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              spreadRadius: 0,
              blurRadius: 6,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            DemoAudioButtonWidget(key: UniqueKey()),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.demoQuestionLabel.tr,
                    style: TextStyle(
                      fontSize: FontSize.M,
                      color: Colors.black54,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      question.question ?? LocaleKeys.demoProceed.tr,
                      style: const TextStyle(
                        fontSize: FontSize.L,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    LocaleKeys.demoPerformAction.tr,
                    style: TextStyle(
                      fontSize: FontSize.M,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  InkWell(
                    onTap: () async {
                      var result = await Get.dialog<bool>(
                        const DemoCloseWarningDialog(),
                      );
                      if (result ?? false) Get.back();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(AssetConstants.goLeft),
                        const SizedBox(width: 4.0),
                        Text(
                          LocaleKeys.demoBackToCourses.tr,
                          style: TextStyle(
                            color: Get.theme.primaryColor,
                            fontWeight: Weight.heavy,
                            decoration: TextDecoration.underline,
                            decorationColor: Get.theme.primaryColor,
                            decorationThickness: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            Text(
              "${currentQuestionIndex + 1}/$totalQuestions",
              style: const TextStyle(
                fontSize: FontSize.xXL,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
