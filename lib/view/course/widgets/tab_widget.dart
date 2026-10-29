import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabWidget extends StatelessWidget {
  final String title;
  final bool isSelected;

  const TabWidget({super.key, required this.title, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Get.theme.primaryColor : const Color(0xFFE3E3E3),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black45),
      ),
    );
  }
}
