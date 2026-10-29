import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/view/widgets/rounded_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class CallMuteButton extends StatelessWidget {
  final int muteSeconds;
  final void Function() onTap;
  final bool isMuted;
  final double size;

  const CallMuteButton({
    super.key,
    required this.muteSeconds,
    required this.onTap,
    required this.isMuted,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: muteSeconds > 0,
      replacement: RoundedButton(
        size: size,
        press: () {
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Warning,
            title: LocaleKeys.liveDisabled.tr,
            subtitle: LocaleKeys.liveYouHaveExhaustedYourMute.tr,
          );
        },
        color: Colors.white.withValues(alpha: 0.1),
        iconColor: Colors.grey,
        iconSrc: AssetConstants.micMutedIcon,
      ),
      child: RoundedButton(
        size: size,
        press: onTap,
        color: isMuted ? Colors.white : Colors.white.withValues(alpha: 0.1),
        iconColor: isMuted ? Colors.red : Colors.white,
        iconSrc: AssetConstants.micMutedIcon,
      ),
    );
  }
}
