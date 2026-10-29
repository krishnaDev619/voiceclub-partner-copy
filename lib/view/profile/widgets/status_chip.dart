import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.text, required this.bgColor});
  final String? text;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    if (text?.isNotEmpty ?? false) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Text(
          text ?? "",
          style: const TextStyle(
            fontSize: FontSize.S,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
