import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/intro_audio_policy_service.dart';
import 'package:voiceclub_partner/data/models/config/language_info.dart';
import 'package:voiceclub_partner/domain/usecases/account/update_language.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/profile/record_voices_screen.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class SelectLanguageBottomSheet extends StatefulWidget {
  final List<LanguageInfo> languages;

  const SelectLanguageBottomSheet({super.key, required this.languages});

  @override
  State<SelectLanguageBottomSheet> createState() =>
      _SelectLanguageBottomSheetState();
}

class _SelectLanguageBottomSheetState extends State<SelectLanguageBottomSheet> {
  final selectedLanguagesIndex = <int>[];

  @override
  void initState() {
    sl<AnalyticsService>().trackEvent(
      "partnerBottomSheetOpen",
      eventProperties: {"bottomSheetType": "SelectLanguageBottomSheet"},
    );
    super.initState();
  }

  void updateLanguageSelection(int index, bool? value) {
    if (value ?? false) {
      if (selectedLanguagesIndex.length < 2) {
        // If less than 2 items, simply add the new item.
        selectedLanguagesIndex.add(index);
      } else {
        // If trying to add a third item:
        // 1. Remove the first item (oldest)
        selectedLanguagesIndex.removeAt(0);
        // 2. Add the new item at the end (as the newest)
        selectedLanguagesIndex.add(index);
      }
    } else {
      selectedLanguagesIndex.remove(index);
    }
    setState(() {});
  }

  void updateLanguage() async {
    if (selectedLanguagesIndex.isNotEmpty) {
      Get.context?.loaderOverlay.show();
      try {
        String firstLanguage = "";
        String secondLanguage = "";
        firstLanguage = widget.languages[selectedLanguagesIndex[0]].code ?? "";
        if (selectedLanguagesIndex.length == 2) {
          secondLanguage =
              widget.languages[selectedLanguagesIndex[1]].code ?? "";
        } else {
          secondLanguage =
              widget.languages[selectedLanguagesIndex[0]].code ?? "";
        }
        var updateLanguageUseCase = sl<UpdateLanguageUseCase>();
        final response = await updateLanguageUseCase.call(
          Params(firstLanguage: firstLanguage, secondLanguage: secondLanguage),
        );
        if (response.error == null) {
          sl<AnalyticsService>().trackEvent(
            "partnerLanguageSelected",
            eventProperties: {
              "languages": [firstLanguage, secondLanguage],
              ...sl<IntroAudioPolicyService>().analyticsProperties,
            },
          );
        }
        await Future.delayed(const Duration(milliseconds: 500));
        await Get.find<UserController>().fetchData();
      } catch (_) {
      } finally {
        Get.context?.loaderOverlay.hide();
        Get.back();
        final userController = Get.find<UserController>();
        if (sl<IntroAudioPolicyService>().shouldShowAccountRecordVoices(
          stage: userController.currentStage,
          hasUploadedAllAudios: userController.hasUploadedAllAudios,
          audioApprovalStatus: userController.audioApprovalStatus,
          accountId: userController.accountId,
        )) {
          Get.to(() => const RecordVoicesScreen());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        width: Get.width,
        constraints: BoxConstraints(maxHeight: Get.height * 0.85),
        child: Container(
          width: Get.width,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
            ),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                LocaleKeys.homeWhichLanguage.tr,
                style: TextStyle(
                  fontSize: FontSize.xL,
                  fontWeight: Weight.heavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                LocaleKeys.homeSelectUptoTwo.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: FontSize.M),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color:
                            selectedLanguagesIndex.contains(index)
                                ? const Color(0xFFFFEDED)
                                : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      margin: const EdgeInsets.all(4.0),
                      child: CheckboxListTile.adaptive(
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.all(0.0),
                        selected: selectedLanguagesIndex.contains(index),
                        value: selectedLanguagesIndex.contains(index),
                        enabled:
                            !(selectedLanguagesIndex.length == 2) ||
                            selectedLanguagesIndex.contains(index),
                        visualDensity: VisualDensity.compact,
                        onChanged: (value) {
                          updateLanguageSelection(index, value);
                        },
                        selectedTileColor: const Color(0xFFFFEDED),
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.languages[index].code ?? "",
                                  style: const TextStyle(
                                    fontWeight: Weight.heavy,
                                    fontSize: FontSize.L,
                                  ),
                                ),
                                Text(
                                  widget.languages[index].description ?? "",
                                  style: const TextStyle(fontSize: FontSize.M),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 54.0,
                              child: SvgPicture.network(
                                widget.languages[index].icon ?? "",
                                colorFilter:
                                    !selectedLanguagesIndex.contains(index)
                                        ? const ColorFilter.mode(
                                          Color(0xFF9A9A9A),
                                          BlendMode.srcIn,
                                        )
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: widget.languages.length,
                ),
              ),
              const SizedBox(height: 10),
              Opacity(
                opacity: selectedLanguagesIndex.isEmpty ? 0.5 : 1.0,
                child: CustomButton(
                  text: LocaleKeys.homeSelectLanguage.tr,
                  onTap: updateLanguage,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
