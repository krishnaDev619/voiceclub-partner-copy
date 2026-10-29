import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/data_controller.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/onboarding_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class EducationQuestion extends StatefulWidget {
  const EducationQuestion({super.key});

  @override
  State<EducationQuestion> createState() => _EducationQuestionState();
}

class _EducationQuestionState extends State<EducationQuestion> {
  int? radioValue;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
      updateStep();
    });
    sl<AnalyticsService>().trackEvent("educationQuestionScreen");
    super.initState();
  }

  void updateStep() {
    Get.find<OnboardingController>().updateCompletedStep(
      step: OnboardingStep.MaritalStatusQuestion,
    );
  }

  void setRadioValue(int? value) {
    if (value != null) {
      setState(() {
        radioValue = value;
      });
    }
  }

  void updateDataModel() {
    String result = "";
    switch (radioValue) {
      case 0:
        result = Education.tenthPass.getEducationString;
      case 1:
        result = Education.twelfthPass.getEducationString;
      case 2:
        result = Education.Bachelor.getEducationString;
      case 3:
        result = Education.Master.getEducationString;
    }
    Get.find<DataController>().onboardingDataModel.value.education = result;
  }

  void initData() {
    final value =
        Get.find<DataController>().onboardingDataModel.value.education;
    int? result;
    if (value == Education.tenthPass.getEducationString) {
      result = 0;
    } else if (value == Education.twelfthPass.getEducationString) {
      result = 1;
    } else if (value == Education.Bachelor.getEducationString) {
      result = 2;
    } else if (value == Education.Master.getEducationString) {
      result = 3;
    }
    setState(() {
      radioValue = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${LocaleKeys.highestEducation.tr}*",
          style: const TextStyle(
            fontSize: FontSize.xL,
            fontWeight: Weight.heavy,
          ),
        ),
        const SizedBox(height: 10.0),
        const Divider(),
        RadioGroup(
          onChanged: setRadioValue,
          groupValue: radioValue,
          child: RadioListTile(
            value: 0,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(LocaleKeys.tenthPass.tr),
          ),
        ),
        RadioGroup(
          onChanged: setRadioValue,
          groupValue: radioValue,
          child: RadioListTile(
            value: 1,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(LocaleKeys.twelfthPass.tr),
          ),
        ),
        RadioGroup(
          onChanged: setRadioValue,
          groupValue: radioValue,
          child: RadioListTile(
            value: 2,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(LocaleKeys.bachelorDegree.tr),
          ),
        ),
        RadioGroup(
          onChanged: setRadioValue,
          groupValue: radioValue,
          child: RadioListTile(
            value: 3,
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(LocaleKeys.masterDegree.tr),
          ),
        ),
        Text(
          "*${LocaleKeys.mandatory.tr}",
          style: const TextStyle(color: ApplicationColors.grey),
        ),
        Spacer(),
        CustomButton(
          text: LocaleKeys.continueLabel.tr,
          enabled: radioValue != null,
          onTap: () {
            if (radioValue == null) return;
            updateDataModel();
            Get.find<OnboardingController>().jumpToNextPage();
          },
        ),
      ],
    );
  }
}
