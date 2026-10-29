import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/chat/widgets/zig_zag_clipper.dart';

class ZigZagContainer extends StatelessWidget {
  const ZigZagContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ZigZagClipper(),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFEE6464),
              Color(0xFFFF7E43),
              Color(0xFFF48465),
              Color(0xFFEE6464),
              Color(0xFFFFC267),
            ],
          ),
        ),
        child: const Text(
          'New Year Offer',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: FontSize.L,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
