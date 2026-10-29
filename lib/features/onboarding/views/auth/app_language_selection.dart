import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/session_router.dart';
import 'package:voiceclub_partner/core/services/ui_localization_service.dart';
import 'package:voiceclub_partner/data/models/localization/ui_language.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/app_language_service.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/auth_controller.dart';
import 'package:voiceclub_partner/features/onboarding/views/auth/widgets/language_widget.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class AppLanguageSelection extends StatefulWidget {
  const AppLanguageSelection({super.key});

  @override
  State<AppLanguageSelection> createState() => _AppLanguageSelectionState();
}

class _AppLanguageSelectionState extends State<AppLanguageSelection> {
  String? selectedCode;

  @override
  void initState() {
    sl<AnalyticsService>().trackEvent("appLanguageSelectionScreen");
    super.initState();
  }

  List<UiLanguage> get _languages => sl<UiLocalizationService>().languages;

  Future<void> continueBtnAction() async {
    final code = selectedCode;
    if (code == null) {
      Get.snackbar(
        LocaleKeys.somethingWentWrong.tr,
        LocaleKeys.pleaseSelectLanguage.tr,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final language = _languages.firstWhere((item) => item.code == code);
    final legacy = language.appLanguage;
    var isSuccess = legacy != null && legacy.isNotEmpty;
    try {
      Get.context?.loaderOverlay.show();
      if (isSuccess) {
        isSuccess = await sl<UiLocalizationService>().setLanguage(code);
      }
      if (isSuccess) {
        await sl<AppLanguageService>().saveLocale(legacy!);
      }
    } catch (_) {
      isSuccess = false;
    } finally {
      Get.context?.loaderOverlay.hide();
      if (isSuccess) {
        sl<AnalyticsService>().trackEvent(
          "appLanguageSelected",
          eventProperties: {"selectedLanguage": legacy},
        );
        await Get.find<AuthController>().updateAppLocale();
        await SessionRouter.onLanguageSelected();
      } else {
        Get.snackbar(
          LocaleKeys.somethingWentWrong.tr,
          LocaleKeys.languageUpdateFailed.tr,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languages = _languages;
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            LocaleKeys.chooseLanguage.tr,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final language = languages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: LanguageWidget(
                        isSelected: selectedCode == language.code,
                        language: language.name,
                        localeAsset: language.icon,
                        onTap: () {
                          setState(() {
                            selectedCode = language.code;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              Opacity(
                opacity: selectedCode != null ? 1.0 : 0.5,
                child: CustomButton(
                  text: LocaleKeys.continueLabel.tr,
                  onTap: selectedCode != null ? continueBtnAction : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
