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

class ReligionQuestion extends StatefulWidget {
  const ReligionQuestion({super.key});

  @override
  State<ReligionQuestion> createState() => _ReligionQuestionState();
}

class _ReligionQuestionState extends State<ReligionQuestion> {
  int? radioValue;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
      updateStep();
    });
    sl<AnalyticsService>().trackEvent("religionQuestionScreen");
    super.initState();
  }

  void updateStep() {
    Get.find<OnboardingController>().updateCompletedStep(
      step: OnboardingStep.EducationQuestion,
    );
  }

  void setRadioValue(int? value) {
    if (value != null) {
      setState(() {
        radioValue = value;
      });
    }
  }

  Future<void> updateDataModel() async {
    String result = "";
    switch (radioValue) {
      case 0:
        result = Religion.Hindu.name;
      case 1:
        result = Religion.Muslim.name;
      case 2:
        result = Religion.Christian.name;
      case 3:
        result = Religion.Others.name;
    }
    Get.find<DataController>().onboardingDataModel.value.religion = result;
    await Get.find<DataController>().updateData(
      isLastUpdate: true,
      profileStatus: ProfileStatus.APPROVED,
      shouldNavigate: true,
    );
  }

  void initData() {
    final value = Get.find<DataController>().onboardingDataModel.value.religion;
    int? result;
    if (value == Religion.Hindu.name) {
      result = 0;
    } else if (value == Religion.Muslim.name) {
      result = 1;
    } else if (value == Religion.Christian.name) {
      result = 2;
    } else if (value == Religion.Others.name) {
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
          "${LocaleKeys.selectReligion.tr}*",
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
            title: Text(LocaleKeys.hindu.tr),
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
            title: Text(LocaleKeys.muslim.tr),
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
            title: Text(LocaleKeys.christian.tr),
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
            title: Text(LocaleKeys.others.tr),
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
          },
        ),
      ],
    );
  }
}
