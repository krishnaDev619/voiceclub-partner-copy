import 'package:flutter/material.dart';

class ZigZagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final height = size.height;
    final width = size.width;
    final zigZagWidth = height / 3;

    path.moveTo(0, 0); // Move to the top-left corner

    for (double i = 0; i < height; i += zigZagWidth) {
      path.lineTo(zigZagWidth, i + zigZagWidth / 2);
      path.lineTo(0, i + zigZagWidth);
    }

    path.lineTo(width, height); // Line back to the top-right corner

    for (double i = height; i > 0; i -= zigZagWidth) {
      path.lineTo(width - zigZagWidth, i - zigZagWidth / 2);
      path.lineTo(width, i - zigZagWidth);
    }
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
