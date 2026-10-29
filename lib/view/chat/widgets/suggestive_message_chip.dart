import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SuggestiveMessageChip extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const SuggestiveMessageChip({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6.0),
        constraints: BoxConstraints(maxWidth: Get.width / 2),
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 0.5, color: const Color(0xFFCECECE)),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
