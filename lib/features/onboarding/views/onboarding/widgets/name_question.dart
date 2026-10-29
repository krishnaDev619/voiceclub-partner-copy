import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/data_controller.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/onboarding_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/views/widgets/custom_text_field.dart';

class NameQuestion extends StatefulWidget {
  const NameQuestion({super.key});

  @override
  State<NameQuestion> createState() => _NameQuestionState();
}

class _NameQuestionState extends State<NameQuestion> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initData();
    });
    sl<AnalyticsService>().trackEvent("nameQuestionScreen");
    super.initState();
  }

  void updateDataModel() {
    var fullName =
        "${firstNameController.text.trim()} ${lastNameController.text.trim()}";
    Get.find<DataController>().onboardingDataModel.value.name = fullName.trim();
  }

  void initData() {
    final value = Get.find<DataController>().onboardingDataModel.value.name;
    List<String> valueList = [];
    if (value != null) {
      valueList = value.split(" ");
    }
    firstNameController.text = valueList.firstOrNull ?? "";
    if (valueList.length > 1) {
      lastNameController.text = valueList.lastOrNull ?? "";
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${LocaleKeys.whatIsYourName.tr}*",
          style: const TextStyle(
            fontSize: FontSize.xL,
            fontWeight: Weight.heavy,
          ),
        ),
        const SizedBox(height: 10.0),
        const Divider(),
        const SizedBox(height: 10.0),
        CustomTextField(
          name: LocaleKeys.firstName.tr,
          controller: firstNameController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
          ],
          keyboardType: TextInputType.name,
          onChanged: (_) {
            setState(() {});
          },
        ),
        const SizedBox(height: 10.0),
        CustomTextField(
          name: LocaleKeys.lastName.tr,
          controller: lastNameController,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
          ],
          keyboardType: TextInputType.name,
          onChanged: (_) {
            setState(() {});
          },
        ),
        const SizedBox(height: 10.0),
        Text(
          "*${LocaleKeys.mandatory.tr}",
          style: const TextStyle(color: ApplicationColors.grey),
        ),
        Spacer(),
        CustomButton(
          text: LocaleKeys.continueLabel.tr,
          enabled: firstNameController.text.length >= 3,
          onTap: () {
            FocusScope.of(context).unfocus();
            updateDataModel();
            Get.find<OnboardingController>().jumpToNextPage();
          },
        ),
      ],
    );
  }
}
