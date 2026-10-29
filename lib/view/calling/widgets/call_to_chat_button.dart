import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallToChatButton extends StatelessWidget {
  final void Function() onTap;

  const CallToChatButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20.0, top: 10.0),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 48.0),
        decoration: BoxDecoration(
          color: Get.theme.primaryColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, color: Colors.white),
            SizedBox(width: 10),
            Text(
              "Chat",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
