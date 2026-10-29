import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CloseBottomSheetButton extends StatelessWidget {
  final VoidCallback? onBack;

  const CloseBottomSheetButton({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBack ?? Get.back,
      child: const Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: CircleAvatar(
          radius: 16.0,
          backgroundColor: Colors.black26,
          child: Padding(
            padding: EdgeInsets.all(3.0),
            child: Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}
