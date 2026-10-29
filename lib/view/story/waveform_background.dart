import 'package:flutter/material.dart';

class WaveformBackground extends StatelessWidget {
  const WaveformBackground({super.key, required this.width});
  final double width;
  @override
  Widget build(BuildContext context) {
    final maxContainers = calculateMaxContainers(width);
    return Row(
      children: List.generate(
        maxContainers,
        (index) => Container(
          width: 4.0,
          height: 4.0,
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD9D9D9),
          ),
        ),
      ),
    );
  }

  int calculateMaxContainers(double availableWidth) {
    const containerWidth = 4.0 + 4.0; // Diameter + Margin
    final maxContainers = (availableWidth / containerWidth).floor();
    return maxContainers;
  }
}
