import 'dart:math';

import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class SemiCircularProgressIndicator extends StatelessWidget {
  final double progress; // Progress value between 0 and 1
  final double width;
  final Color? backgroundColor;
  final Color? arcColor;
  final String? text;

  const SemiCircularProgressIndicator({
    super.key,
    required this.progress,
    required this.width,
    this.backgroundColor,
    this.arcColor,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(width, width / 2), // Adjust size as needed
          painter: ArcIndicator(
            width: 12.0,
            backgroundColor: backgroundColor ?? const Color(0xFFD3D3D3),
            lineColor: arcColor ?? Colors.white,
            percent: progress,
          ),
        ),
        if (text != null)
          Transform.translate(
            offset: const Offset(0.0, -10.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: (width / 2) - 32.0,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text ?? "",
                    style: const TextStyle(
                      fontSize: FontSize.xXXXL,
                      fontWeight: Weight.heavy,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
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
      -pi,
      pi,
      false,
      bgLine,
    );
    double sweepAngle = pi * percent;
    canvas.drawArc(
      Rect.fromCircle(center: offset, radius: radius),
      pi,
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
