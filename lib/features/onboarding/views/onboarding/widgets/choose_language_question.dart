import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/ui_localization_service.dart';
import 'package:voiceclub_partner/data/models/localization/ui_language.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/app_language_service.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/auth_controller.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/data_controller.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/onboarding_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class ChooseLanguageQuestion extends StatefulWidget {
  const ChooseLanguageQuestion({super.key});

  @override
  State<ChooseLanguageQuestion> createState() => _ChooseLanguageQuestionState();
}

class _ChooseLanguageQuestionState extends State<ChooseLanguageQuestion> {
  final languageList =
      Language.values
          .map((language) => LanguageSelectionModel(language, false))
          .toList();
  final keyList = List.generate(Language.values.length, (_) => GlobalKey());
  final selectedLanguagesList = <Language>[];
  AppLanguage currentAppLanguage =
      Get.find<AuthController>().currentAppLocale.value;
  Language? lockedLanguage;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pending = await sl<AppLanguageService>().readDeeplinkLanguage();
      if (!mounted) return;
      final deeplinkLanguage = Language.values.firstWhereOrNull(
        (language) =>
            language.name.toLowerCase() == pending?.trim().toLowerCase(),
      );
      lockedLanguage = resolveLockedSpeakingLanguage(
        deeplinkLanguage: deeplinkLanguage,
        selectedUiLanguage: _selectedUiLanguage(),
      );
      initData();
      _moveLockedLanguageToTop();
      interchangeBasedOnLanguage();
      updateStep();
      setState(() {});
    });
    sl<AnalyticsService>().trackEvent("languageQuestionScreen");
    super.initState();
  }

  UiLanguage? _selectedUiLanguage() {
    final localization = sl<UiLocalizationService>();
    final code = localization.selectedCode;
    if (code == null || code.isEmpty) return null;
    return localization.languages.firstWhereOrNull(
      (language) => language.code.toLowerCase() == code.toLowerCase(),
    );
  }

  void updateStep() {
    Get.find<OnboardingController>().updateCompletedStep(
      step: OnboardingStep.NameQuestion,
    );
  }

  void interchangeBasedOnLanguage() {
    if (lockedLanguage != null || languageList.isEmpty) return;
    if (currentAppLanguage == AppLanguage.Tamil) {
      final tamilLanguageIndex = languageList.indexWhere(
        (element) => element.language == Language.Tamil,
      );
      if (tamilLanguageIndex < 0) return;
      final temp = languageList.first;
      languageList.first = languageList[tamilLanguageIndex];
      languageList[tamilLanguageIndex] = temp;
    } else if (currentAppLanguage == AppLanguage.Telugu) {
      if (languageList.length < 3) return;
      final teluguLanguageIndex = languageList.indexWhere(
        (element) => element.language == Language.Telugu,
      );
      if (teluguLanguageIndex < 0) return;
      final temp = languageList[2];
      languageList[2] = languageList[teluguLanguageIndex];
      languageList[teluguLanguageIndex] = temp;
      final tamilLanguageIndex = languageList.indexWhere(
        (element) => element.language == Language.Tamil,
      );
      if (tamilLanguageIndex < 0) return;
      final temp2 = languageList[1];
      languageList[1] = languageList[tamilLanguageIndex];
      languageList[tamilLanguageIndex] = temp2;
    }
  }

  void _moveLockedLanguageToTop() {
    final locked = lockedLanguage;
    if (locked == null) return;
    final index = languageList.indexWhere((item) => item.language == locked);
    if (index <= 0) return;
    final item = languageList.removeAt(index);
    languageList.insert(0, item);
  }

  bool _isLocked(Language language) => language == lockedLanguage;

  void _keepLockedLanguageSelected() {
    final locked = lockedLanguage;
    if (locked == null) return;
    languageList.firstWhereOrNull((e) => e.language == locked)?.checked = true;
    selectedLanguagesList.remove(locked);
    selectedLanguagesList.insert(0, locked);
  }

  void onChanged(bool? value, int index) {
    if (_isLocked(languageList[index].language)) return;
    setState(() {
      if (selectedLanguagesList.contains(languageList[index].language)) {
        selectedLanguagesList.remove(languageList[index].language);
        languageList[index].checked = value ?? false;
      } else if (selectedLanguagesList.length < 2) {
        languageList[index].checked = value ?? false;
        selectedLanguagesList.add(languageList[index].language);
      }
    });
  }

  void chooseAnotherLanguageAlert() {
    Get.dialog(
      AlertDialog(
        title: Text(
          LocaleKeys.chooseAnotherLanguage.tr,
          style: const TextStyle(fontSize: FontSize.xXL),
        ),
        content: Text(LocaleKeys.chooseTwoLanguages.tr),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(LocaleKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              updateOnboardingDataModel();
              Get.find<OnboardingController>().jumpToNextPage();
            },
            child: Text(LocaleKeys.continueLabel.tr),
          ),
        ],
      ),
    );
  }

  void updateOnboardingDataModel() {
    _keepLockedLanguageSelected();
    var firstLanguage = selectedLanguagesList.first;
    var secondLanguage = firstLanguage;
    if (selectedLanguagesList.length > 1) {
      secondLanguage = selectedLanguagesList.last;
    }
    Get.find<DataController>().onboardingDataModel.value.firstLanguage =
        firstLanguage.name;
    Get.find<DataController>().onboardingDataModel.value.secondLanguage =
        secondLanguage.name;
    Get.find<DataController>().selectedFirstLanguage.value = firstLanguage;
  }

  void initData() {
    selectedLanguagesList.clear();
    for (final item in languageList) {
      item.checked = false;
    }

    final firstLanguage =
        Get.find<DataController>().onboardingDataModel.value.firstLanguage;
    final secondLanguage =
        Get.find<DataController>().onboardingDataModel.value.secondLanguage;
    final bothSame = firstLanguage == secondLanguage;
    final previouslySelected =
        Get.find<DataController>().selectedFirstLanguage.value;

    if (lockedLanguage == null) {
      if (previouslySelected != null) {
        selectedLanguagesList.add(previouslySelected);
        languageList
            .firstWhereOrNull((e) => e.language == previouslySelected)
            ?.checked = true;
      } else if (firstLanguage?.isNotEmpty ?? false) {
        final lang = firstLanguage!.toLanguage();
        selectedLanguagesList.add(lang);
        languageList.firstWhereOrNull((e) => e.language == lang)?.checked =
            true;
      }
    } else {
      _keepLockedLanguageSelected();
    }

    if ((secondLanguage?.isNotEmpty ?? false) && !bothSame) {
      final lang = secondLanguage!.toLanguage();
      if (lang != lockedLanguage && !selectedLanguagesList.contains(lang)) {
        selectedLanguagesList.add(lang);
        languageList.firstWhereOrNull((e) => e.language == lang)?.checked =
            true;
      }
    }

    _keepLockedLanguageSelected();
  }

  @override
  Widget build(BuildContext context) {
    final locked = lockedLanguage;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${LocaleKeys.chooseLanguage.tr}*",
          style: const TextStyle(
            fontSize: FontSize.xL,
            fontWeight: Weight.heavy,
          ),
        ),
        const SizedBox(height: 10.0),
        const Divider(),
        Text(LocaleKeys.chooseComfortableLanguage.tr),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int index = 0; index < languageList.length; index++)
                  CheckboxListTile(
                    key: keyList[index],
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: languageList[index].checked,
                    visualDensity: VisualDensity.compact,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      languageList[index].language.name,
                      style: TextStyle(
                        color:
                            _isLocked(languageList[index].language)
                                ? ApplicationColors.grey
                                : null,
                      ),
                    ),
                    onChanged:
                        _isLocked(languageList[index].language)
                            ? null
                            : (value) {
                              onChanged(value, index);
                            },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Text(
          locked == null
              ? "*1 ${LocaleKeys.mandatory.tr} (${LocaleKeys.max.tr} 2)"
              : "*${locked.name} ${LocaleKeys.mandatory.tr} (${LocaleKeys.max.tr} 2)",
          style: const TextStyle(color: ApplicationColors.grey),
        ),
        const SizedBox(height: 10.0),
        CustomButton(
          text: LocaleKeys.continueLabel.tr,
          enabled: selectedLanguagesList.isNotEmpty,
          onTap: () {
            if (selectedLanguagesList.length == 1) {
              chooseAnotherLanguageAlert();
            } else {
              updateOnboardingDataModel();
              Get.find<OnboardingController>().jumpToNextPage();
            }
          },
        ),
      ],
    );
  }
}

class LanguageSelectionModel {
  Language language;
  bool checked;

  LanguageSelectionModel(this.language, this.checked);
}

/// English UI keeps the free 2-language pick. Any other UI language (or a
/// deeplink language) is locked as the partner's first speaking language.
Language? resolveLockedSpeakingLanguage({
  Language? deeplinkLanguage,
  UiLanguage? selectedUiLanguage,
}) {
  if (deeplinkLanguage != null) return deeplinkLanguage;
  if (selectedUiLanguage == null) return null;
  if (_isEnglishUiLanguage(selectedUiLanguage)) return null;
  final token =
      selectedUiLanguage.appLanguage?.trim().isNotEmpty == true
          ? selectedUiLanguage.appLanguage!
          : selectedUiLanguage.name;
  return Language.values.firstWhereOrNull(
    (language) =>
        language.name.toLowerCase() == token.toLowerCase() ||
        selectedUiLanguage.matchesToken(language.name),
  );
}

bool _isEnglishUiLanguage(UiLanguage language) {
  final code = language.code.trim().toLowerCase();
  if (code == 'en' || code.startsWith('en_') || code.startsWith('en-')) {
    return true;
  }
  return language.appLanguage?.trim().toLowerCase() == 'english';
}
