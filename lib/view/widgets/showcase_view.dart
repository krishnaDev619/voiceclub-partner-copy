import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomShowcaseTooltip extends StatelessWidget {
  final String title;
  final double angle;

  const CustomShowcaseTooltip({
    super.key,
    required this.title,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width - 80.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Transform.rotate(
              angle: angle,
              child: const Text("👆", style: TextStyle(fontSize: 42.0)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 40.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: FittedBox(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
