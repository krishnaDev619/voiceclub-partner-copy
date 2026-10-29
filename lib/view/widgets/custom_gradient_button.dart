import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class CustomGradientButton extends StatelessWidget {
  final VoidCallback press;
  final String text;
  final LinearGradient? gradientColors;
  final Widget? child;
  final EdgeInsets? margin;

  const CustomGradientButton({
    super.key,
    required this.press,
    required this.text,
    this.gradientColors,
    this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        margin: margin,
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient:
              gradientColors ??
              const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFEEDA9),
                  Color(0xFFFFE7AA),
                  Color(0xFFFD9903),
                ],
              ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child:
              child ??
              Text(
                text,
                style: const TextStyle(
                  fontWeight: Weight.bold,
                  fontSize: FontSize.xXXL,
                ),
              ),
        ),
      ),
    );
  }
}
