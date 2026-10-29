import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/tutorial/tutorial_stage_model.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/semi_circular_progress_indicator.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/controllers/tutorial_lesson_controller.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/widgets/lesson_step_widget.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/widgets/stepper_controls_button.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';

class TutorialLessonScreen extends StatefulWidget {
  final bool isFromNormalApp;

  const TutorialLessonScreen({super.key, this.isFromNormalApp = false});

  @override
  State<TutorialLessonScreen> createState() => _TutorialLessonScreenState();
}

class _TutorialLessonScreenState extends State<TutorialLessonScreen> {
  late PageController _pageController;

  final _lessonController = Get.find<TutorialLessonController>();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _lessonController.currentVisiblePageIndex.value,
    );
    _lessonController.trackPartnerTutorialScreenEvent(screenName: 'Landing');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int getCurrentStep(int index, TutorialStageModel visibleStage) {
    if (index == _lessonController.currentStageIndex) {
      return _lessonController.currentLessonIndex < visibleStage.lessons!.length
          ? _lessonController.currentLessonIndex
          : visibleStage.lessons!.length - 1;
    } else if (index < _lessonController.currentStageIndex) {
      return visibleStage.lessons!.length - 1;
    } else {
      return 0;
    }
  }

  bool isLessonCompleted(int stageIndex, int lessonIndex) {
    if (stageIndex < _lessonController.currentStageIndex) return true;

    return stageIndex == _lessonController.currentStageIndex &&
        lessonIndex <= _lessonController.completedLessonIndex.value;
  }

  @override
  Widget build(BuildContext context) {
    // final userController = Get.find<UserController>();
    return Obx(() {
      final stages = _lessonController.stages;
      return Scaffold(
        backgroundColor: const Color(0xFFFFD0D0),
        body: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFD0D0), Colors.white],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20.0),
                  Text(
                    LocaleKeys.journeyStageNumber.trParams({
                      'stage':
                          '${_lessonController.currentVisiblePageIndex.value + 1}',
                    }),
                    style: const TextStyle(
                      fontWeight: Weight.bold,
                      fontSize: 22.0,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_left_outlined,
                          size: 36.0,
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0.0, 24.0),
                        child: SemiCircularProgressIndicator(
                          width: 240.0,
                          progress: _lessonController.progressPercentage,
                          backgroundColor: const Color(0xFFEFEFEF),
                          arcColor: Colors.green,
                          text:
                              "${(_lessonController.progressPercentage * 100).toStringAsFixed(0)}%",
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_right_outlined,
                          size: 36.0,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: stages.length,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (value) {
                          _lessonController.currentVisiblePageIndex(value);
                        },
                        itemBuilder: (context, index) {
                          final stage = stages[index];
                          if (stage.lessons?.isNotEmpty ?? false) {
                            return Stepper(
                              key: UniqueKey(),
                              currentStep: getCurrentStep(index, stage),
                              controlsBuilder: (context, details) {
                                final lesson =
                                    stage.lessons?[details.currentStep];
                                return Visibility(
                                  visible:
                                      _lessonController.currentStageIndex ==
                                              index
                                          ? !_lessonController
                                              .showContinueButton
                                              .value
                                          : true,
                                  replacement: const SizedBox(width: 300.0),
                                  child: Disabled(
                                    disabled:
                                        _lessonController.currentStageIndex !=
                                        index,
                                    child: StepperControlsButton(
                                      lesson: lesson!,
                                      stageId: stage.id ?? 0,
                                      lessonIndex: details.currentStep,
                                    ),
                                  ),
                                );
                              },
                              steps:
                                  stages[index].lessons!
                                      .asMap()
                                      .entries
                                      .map<Step>((entry) {
                                        final lessonIndex = entry.key;
                                        final lesson = entry.value;

                                        return LessonStepWidget(
                                          isCompleted: isLessonCompleted(
                                            index,
                                            lessonIndex,
                                          ),
                                          title:
                                              lesson.title ??
                                              LocaleKeys.sampleLesson.tr,
                                          currentStep:
                                              _lessonController
                                                          .currentStageIndex ==
                                                      index
                                                  ? _lessonController
                                                      .currentLessonIndex
                                                  : -1,
                                          lesson: lesson,
                                          stageId: stages[index].id ?? 0,
                                          stepIndex: lessonIndex,
                                        ).buildStep();
                                      })
                                      .toList(),
                            );
                          } else {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    AssetConstants.unlockBig,
                                    width: 150.0,
                                    height: 150.0,
                                  ),
                                  Text(LocaleKeys.noLessonsInThisStage.tr),
                                  const SizedBox(height: 42.0),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible:
                        _lessonController.currentStageIndex ==
                            _lessonController.currentVisiblePageIndex.value &&
                        _lessonController.showContinueButton.value &&
                        !widget.isFromNormalApp,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomButton(
                        text: _quizButtonLabel(_lessonController.currentStage),
                        onTap: () {
                          _lessonController.onContinueButtonPressed();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

String _quizButtonLabel(TutorialStageModel stage) {
  final type = stage.quiz?.type;
  if (type == TutorialQuizType.DEMO) return LocaleKeys.startDemoQuiz.tr;
  if (type == TutorialQuizType.MCQ) return LocaleKeys.startMcqQuiz.tr;
  return LocaleKeys.continueLabel.tr;
}
