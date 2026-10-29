import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class OnboardingStatusChip extends StatelessWidget {
  final RecordingAudioStatus status;
  final Color color;
  final IconData icon;
  const OnboardingStatusChip({
    super.key,
    required this.status,
    required this.color,
    required this.icon,
  });

  String _statusLabel(RecordingAudioStatus status) {
    return status.toLocalizedStatusLabel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(color: color, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12.0),
          const SizedBox(width: 2.0),
          Text(
            _statusLabel(status),
            style: TextStyle(fontSize: FontSize.xS, color: color),
          ),
        ],
      ),
    );
  }
}
