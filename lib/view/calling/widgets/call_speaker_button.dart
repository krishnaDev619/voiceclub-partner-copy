import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/view/widgets/rounded_button.dart';

class CallSpeakerButton extends StatelessWidget {
  final void Function() onTap;
  final bool isSpeaker;
  final double size;
  const CallSpeakerButton({
    super.key,
    required this.onTap,
    required this.isSpeaker,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      size: size,
      press: onTap,
      color: isSpeaker ? Colors.white : Colors.white.withValues(alpha: 0.1),
      iconColor: isSpeaker ? Colors.black : Colors.white,
      iconSrc: AssetConstants.volumeIcon,
    );
  }
}
