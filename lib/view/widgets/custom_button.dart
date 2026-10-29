import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final bool filled;
  final bool enabled;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    this.filled = true,
    required this.onTap,
    this.enabled = true,
    this.color,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0),
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Container(
        width: width ?? double.infinity,
        alignment: Alignment.center,
        padding: padding,
        decoration: BoxDecoration(
          color:
              filled
                  ? enabled
                      ? color ?? Get.theme.primaryColor
                      : color?.withValues(alpha: 0.5) ??
                          Get.theme.primaryColor.withValues(alpha: 0.5)
                  : Colors.transparent,
          border: Border.all(
            color:
                enabled ? color ?? Get.theme.primaryColor : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: filled ? Colors.white : color ?? Get.theme.primaryColor,
            fontSize: FontSize.L,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
