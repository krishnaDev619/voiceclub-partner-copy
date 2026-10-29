import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/semi_circular_progress_indicator.dart';
import 'package:voiceclub_partner/view/onboarding/controller/onboarding_progress_controller.dart';
import 'package:voiceclub_partner/view/onboarding/widgets/onboarding_stepper_button.dart';
import 'package:voiceclub_partner/view/onboarding/widgets/step_widget.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class OnboardingProgressScreen extends StatefulWidget {
  const OnboardingProgressScreen({super.key});

  @override
  State<OnboardingProgressScreen> createState() =>
      _OnboardingProgressScreenState();
}

class _OnboardingProgressScreenState extends State<OnboardingProgressScreen> {
  final controller = Get.find<OnboardingProgressController>();

  @override
  void initState() {
    super.initState();
    controller.fetchOnboardingStatus(true);
  }

  List<Step> getSteps({required OnboardingStep cStep}) {
    return [
      StepWidget(
        title: LocaleKeys.addProfileAudio.tr,
        subtitle: LocaleKeys.addProfileAudioSubtitle.tr,
        approvalStatus: controller.audioApprovalStatus.value,
        isCompleted: controller.hasUploadedAudios.value,
        stepIndex: OnboardingStep.PROFILE_AUDIO,
        currentStep: cStep,
      ).buildStep(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    sl<AnalyticsService>().trackEvent(
      'onboardingProgressScreen',
      eventProperties: controller.getCommonEventProperties,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFFFD0D0),
      body: SafeArea(
        child: Container(
          height: Get.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD0D0), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchOnboardingStatus(false);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Obx(() {
                final cStep = controller.currentStep.value;
                if (controller.isLoading.value) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: Get.height / 2.5),
                      child: const CircularProgressIndicator(),
                    ),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16.0,
                          16.0,
                          16.0,
                          80.0,
                        ),
                        child: Column(
                          children: [
                            Text(
                              LocaleKeys.welcomeToVoiceClub.tr,
                              style: const TextStyle(
                                fontSize: FontSize.xXL,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(0.0, 32.0),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SemiCircularProgressIndicator(
                                    width: 240.0,
                                    progress: controller.progress,
                                    backgroundColor: const Color(0xFFCBC5C5),
                                    arcColor: Colors.white,
                                    text:
                                        "${(controller.progress * 100).toStringAsFixed(0)}%",
                                  ),
                                  Positioned(
                                    bottom: 24.0,
                                    child: Text(
                                      controller.title.value,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: FontSize.L,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 32.0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 0.0,
                                vertical: 24.0,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.0),
                                color: const Color(0xFFFFF7F7),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2.0,
                                    spreadRadius: 1.0,
                                  ),
                                ],
                              ),
                              child: Stepper(
                                currentStep: controller.getCurrentStepIndex(),
                                physics: const NeverScrollableScrollPhysics(),
                                controlsBuilder: (BuildContext context, _) {
                                  if (controller.isOnboardingCompleted) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.0,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  return OnboardingStepperButton(
                                    currentStep: cStep,
                                    onTap: controller.stepNavigation,
                                  );
                                },
                                steps: getSteps(cStep: cStep),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 70.0),
                      _bottomInfoSection(),
                      const SizedBox(height: 70.0),
                    ],
                  );
                }
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomInfoSection() {
    return Visibility(
      visible: controller.isAnyAudioPending.value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.red.shade300, width: 1.0),
            bottom: BorderSide(color: Colors.red.shade300, width: 1.0),
          ),
        ),
        child: Text(
          LocaleKeys.onceYourAudioIsApproved.tr,
          style: TextStyle(
            color: Colors.red.shade500,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
