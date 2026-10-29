import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class QuestionWidget extends StatefulWidget {
  final List<String> questions;
  final String label;

  const QuestionWidget({
    super.key,
    required this.questions,
    required this.label,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  int currentQuestionIndex = 0;

  void nextQuestion() {
    setState(() {
      currentQuestionIndex =
          (currentQuestionIndex + 1) % widget.questions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: const Offset(0.0, 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: FittedBox(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: FontSize.M,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 40.0,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 42.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: Text(
              widget.questions[currentQuestionIndex],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: FontSize.L,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0.0, -16.0),
            child: GestureDetector(
              onTap: nextQuestion,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16.0,
                child: Icon(
                  Icons.repeat_rounded,
                  size: 18.0,
                  color: Get.theme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
