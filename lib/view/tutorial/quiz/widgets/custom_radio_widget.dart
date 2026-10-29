import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';

class CustomRadioWidget extends StatelessWidget {
  final bool isSelected;
  final AnswerState? answerState;

  const CustomRadioWidget({
    super.key,
    required this.isSelected,
    this.answerState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            !isSelected
                ? Border.all(color: const Color(0xFFEEEFF2), width: 2)
                : null,
        shape: BoxShape.circle,
      ),
      margin: const EdgeInsets.all(12.0),
      child: CircleAvatar(
        radius: 14.0,
        backgroundColor:
            isSelected
                ? answerState != null
                    ? answerState == AnswerState.Correct
                        ? const Color(0xFF89B94C)
                        : const Color(0xFFE21616)
                    : null
                : null,
        child: Center(
          child:
              isSelected
                  ? Icon(
                    answerState != null
                        ? answerState == AnswerState.Correct
                            ? Icons.done
                            : Icons.close
                        : Icons.circle,
                    color:
                        isSelected
                            ? answerState != null
                                ? null
                                : Colors.grey.shade700
                            : null,
                    size: 24.0,
                  )
                  : null,
        ),
      ),
    );
  }
}
