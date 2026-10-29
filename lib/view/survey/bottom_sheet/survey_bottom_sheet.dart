import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/survey/survey_model.dart';
import 'package:voiceclub_partner/view/survey/controllers/survey_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class SurveyBottomSheet extends StatefulWidget {
  final SurveyModel survey;
  final int count;
  const SurveyBottomSheet({
    super.key,
    required this.survey,
    required this.count,
  });

  @override
  State<SurveyBottomSheet> createState() => _SurveyBottomSheetState();
}

class _SurveyBottomSheetState extends State<SurveyBottomSheet> {
  late final SurveyController controller;
  String? selectedMCQOption;
  List<String> selectedCheckboxOptions = [];
  String shortAnswerText = '';

  @override
  void initState() {
    super.initState();
    controller = SurveyController(survey: widget.survey, count: widget.count);
    // Listen to currentIndex changes to reset selected options
    ever(controller.currentIndex, (index) {
      if (mounted) {
        setState(() {
          selectedMCQOption = null;
          selectedCheckboxOptions = [];
          shortAnswerText = '';
        });
      }
    });
  }

  bool _isNextButtonEnabled() {
    if (controller.survey.type == SurveyType.MCQ) {
      return selectedMCQOption != null;
    } else if (controller.survey.type == SurveyType.CHECKBOX) {
      return selectedCheckboxOptions.isNotEmpty;
    } else if (controller.survey.type == SurveyType.SHORT) {
      return shortAnswerText.trim().isNotEmpty;
    }
    return true; // For other question types, always enable
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(() {
        if (controller.isCompleted.value) {
          return _ThankYouScreen();
        }
        if (!controller.isStarted.value) {
          return _StartSurveyScreen(onStart: () => controller.next());
        }
        final question =
            controller.survey.questions[controller.currentIndex.value];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Container(
              width: Get.width,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SurveyProgress(
                    current: controller.currentIndex.value + 1,
                    total: controller.survey.questions.length,
                  ),
                  const SizedBox(height: 16),
                  if (controller.survey.type == SurveyType.MCQ)
                    _MCQQuestionWidget(
                      question: question,
                      selectedOption: selectedMCQOption,
                      onSelected: (ans) {
                        setState(() {
                          selectedMCQOption = ans;
                        });
                        controller.answerCurrent(ans);
                      },
                    )
                  else if (controller.survey.type == SurveyType.CHECKBOX)
                    _CheckboxQuestionWidget(
                      question: question,
                      selectedOptions: selectedCheckboxOptions,
                      onSelected: (ans) {
                        setState(() {
                          selectedCheckboxOptions = ans;
                        });
                        controller.answerCurrent(ans);
                      },
                    )
                  else if (controller.survey.type == SurveyType.SHORT)
                    _ShortAnswerQuestionWidget(
                      question: question,
                      text: shortAnswerText,
                      onTextChanged: (text) {
                        setState(() {
                          shortAnswerText = text;
                        });
                      },
                    ),
                  const SizedBox(height: 16),
                  // Navigation buttons for all question types
                  Row(
                    children: [
                      if (controller.currentIndex.value > 0)
                        TextButton(
                          onPressed: controller.previous,
                          child: Text(
                            'Previous',
                            style: TextStyle(
                              color: Get.theme.primaryColor,
                              fontSize: FontSize.L,
                            ),
                          ),
                        ),
                      const Spacer(),
                      TextButton(
                        onPressed:
                            _isNextButtonEnabled()
                                ? () {
                                  // For short answer questions, submit the answer before moving to next
                                  if (controller.survey.type ==
                                      SurveyType.SHORT) {
                                    controller.answerCurrent(shortAnswerText);
                                  }
                                  controller.next();
                                }
                                : null,
                        child: Text(
                          controller.currentIndex.value ==
                                  controller.survey.questions.length - 1
                              ? 'Submit'
                              : 'Next',
                          style: TextStyle(
                            color:
                                _isNextButtonEnabled()
                                    ? Get.theme.primaryColor
                                    : Colors.grey,
                            fontSize: FontSize.L,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SurveyProgress extends StatelessWidget {
  final int current;
  final int total;
  const _SurveyProgress({required this.current, required this.total});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question $current of $total',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: current / total),
      ],
    );
  }
}

class _StartSurveyScreen extends StatelessWidget {
  final VoidCallback onStart;
  const _StartSurveyScreen({required this.onStart});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ),
        Container(
          width: Get.width,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AssetConstants.startSurvey, height: 180),
              const SizedBox(height: 24),
              const Text(
                'Survey',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Please take a moment to complete this survey. Your feedback helps us improve our service.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              CustomButton(onTap: onStart, text: LocaleKeys.liveStartSurvey.tr),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThankYouScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ),
        Container(
          width: Get.width,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AssetConstants.thanksSurvey, height: 180),
              const SizedBox(height: 24),
              const Text(
                'Thank You',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// The following widgets should be moved to lib/view/bottom_sheet/widgets/survey/ for clean code in a real project.
class _MCQQuestionWidget extends StatefulWidget {
  final SurveyQuestion question;
  final String? selectedOption;
  final ValueChanged<String> onSelected;

  const _MCQQuestionWidget({
    required this.question,
    required this.selectedOption,
    required this.onSelected,
  });
  @override
  State<_MCQQuestionWidget> createState() => _MCQQuestionWidgetState();
}

class _MCQQuestionWidgetState extends State<_MCQQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        RadioGroup<String>(
          onChanged: (val) {
            HapticFeedback.lightImpact();
            widget.onSelected(val!);
          },
          groupValue: widget.selectedOption,
          child: Column(
            children:
                widget.question.options
                    ?.map(
                      (opt) =>
                          RadioListTile<String>(title: Text(opt), value: opt),
                    )
                    .toList() ??
                [],
          ),
        ),
      ],
    );
  }
}

class _CheckboxQuestionWidget extends StatefulWidget {
  final SurveyQuestion question;
  final List<String> selectedOptions;
  final ValueChanged<List<String>> onSelected;
  const _CheckboxQuestionWidget({
    required this.question,
    required this.selectedOptions,
    required this.onSelected,
  });
  @override
  State<_CheckboxQuestionWidget> createState() =>
      _CheckboxQuestionWidgetState();
}

class _CheckboxQuestionWidgetState extends State<_CheckboxQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        ...?widget.question.options?.map(
          (opt) => CheckboxListTile(
            title: Text(opt),
            value: widget.selectedOptions.contains(opt),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) {
              final newSelected = List<String>.from(widget.selectedOptions);
              if (val == true) {
                newSelected.add(opt);
              } else {
                newSelected.remove(opt);
              }
              widget.onSelected(newSelected);
            },
          ),
        ),
      ],
    );
  }
}

class _ShortAnswerQuestionWidget extends StatefulWidget {
  final SurveyQuestion question;
  final String text;
  final ValueChanged<String> onTextChanged;

  const _ShortAnswerQuestionWidget({
    required this.question,
    required this.text,
    required this.onTextChanged,
  });

  @override
  State<_ShortAnswerQuestionWidget> createState() =>
      _ShortAnswerQuestionWidgetState();
}

class _ShortAnswerQuestionWidgetState
    extends State<_ShortAnswerQuestionWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.text;
  }

  @override
  void didUpdateWidget(_ShortAnswerQuestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset the controller when the question changes
    if (oldWidget.question.id != widget.question.id) {
      _controller.clear();
    } else if (oldWidget.text != widget.text) {
      // Sync controller with external text changes
      if (_controller.text != widget.text) {
        _controller.text = widget.text;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.text.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question.text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: LocaleKeys.liveTypeSomething2.tr,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          maxLines: 3,
          onChanged: widget.onTextChanged,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
