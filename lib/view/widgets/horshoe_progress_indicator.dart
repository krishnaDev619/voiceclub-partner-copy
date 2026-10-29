import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class HorshoeProgressIndicator extends StatelessWidget {
  final double progress; // Progress value between 0 and 1
  final double width;
  final double thickness;
  final IconData? iconData;

  const HorshoeProgressIndicator({
    super.key,
    required this.progress,
    required this.width,
    required this.thickness,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: (width / (25 / 3))),
      child: SizedBox(
        height: width,
        width: width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              child:
                  iconData != null
                      ? Icon(iconData, color: Get.theme.primaryColor)
                      : Text(
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.L,
                        ),
                      ),
            ),
            CustomPaint(
              size: Size(width, width), // Adjust size as needed
              painter: ArcIndicator(
                width: thickness,
                backgroundColor: const Color(0xFFD9D9D9),
                lineColor: Get.theme.primaryColor,
                percent: progress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArcIndicator extends CustomPainter {
  final Color backgroundColor;
  final Color lineColor;
  final double percent;
  final double width;
  ArcIndicator({
    required this.backgroundColor,
    required this.lineColor,
    required this.percent,
    required this.width,
  });
  @override
  void paint(Canvas canvas, Size size) {
    Paint bgLine =
        Paint()
          ..color = backgroundColor
          ..strokeCap = StrokeCap.round
          ..strokeWidth = width
          ..style = PaintingStyle.stroke;
    Paint completedLine =
        Paint()
          ..color = lineColor
          ..strokeCap = StrokeCap.round
          ..strokeWidth = width
          ..style = PaintingStyle.stroke;

    Offset offset = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2);
    canvas.drawArc(
      Rect.fromCircle(center: offset, radius: radius),
      pi * (3 / 4),
      3 * pi / 2,
      false,
      bgLine,
    );
    double sweepAngle = (3 * pi / 2) * percent;
    canvas.drawArc(
      Rect.fromCircle(center: offset, radius: radius),
      pi * (3 / 4),
      sweepAngle,
      false,
      completedLine,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
