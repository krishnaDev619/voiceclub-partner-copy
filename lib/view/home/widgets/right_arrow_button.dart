import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RightArrowButton extends StatelessWidget {
  final double size;
  const RightArrowButton({super.key, this.size = 18.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Get.theme.primaryColor.withValues(alpha: 0.12),
      ),
      child: Icon(
        Icons.navigate_next,
        color: Get.theme.primaryColor,
        size: size,
      ),
    );
  }
}
