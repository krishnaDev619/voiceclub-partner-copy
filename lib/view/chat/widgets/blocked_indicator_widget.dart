import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class BlockedIndicatorWidget extends StatelessWidget {
  const BlockedIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.0,
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 80.0),
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: const Text(
        'You blocked this user.',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: FontSize.M,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
