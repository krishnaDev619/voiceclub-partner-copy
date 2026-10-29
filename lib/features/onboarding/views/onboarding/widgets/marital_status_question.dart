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

class MaritalStatusQuestion extends StatefulWidget {
  const MaritalStatusQuestion({super.key});

  @override
  State<MaritalStatusQuestion> createState() => _MaritalStatusQuestionState();
}

class _MaritalStatusQuestionState extends State<MaritalStatusQuestion> {
  int? radioValue;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
      updateStep();
    });
    sl<AnalyticsService>().trackEvent("maritalStatusQuestionScreen");
    super.initState();
  }

  void updateStep() {
    Get.find<OnboardingController>().updateCompletedStep(
      step: OnboardingStep.ChooseLanguageQuestion,
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
        result = MaritalStatus.Married.name;
      case 1:
        result = MaritalStatus.Unmarried.name;
      case 2:
        result = MaritalStatus.Divorced.name;
    }
    Get.find<DataController>().onboardingDataModel.value.maritalStatus = result;
  }

  void initData() {
    final value =
        Get.find<DataController>().onboardingDataModel.value.maritalStatus;
    int? result;
    if (value == MaritalStatus.Married.name) {
      result = 0;
    } else if (value == MaritalStatus.Unmarried.name) {
      result = 1;
    } else if (value == MaritalStatus.Divorced.name) {
      result = 2;
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
          "${LocaleKeys.maritalStatus.tr}*",
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
            title: Text(LocaleKeys.married.tr),
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
            title: Text(LocaleKeys.unmarried.tr),
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
            title: Text(LocaleKeys.divorced.tr),
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
