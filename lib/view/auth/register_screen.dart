import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/auth_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Please register as a VoiceClub Partner to continue.",
                textAlign: TextAlign.center,
              ),
            ),
            TextButton(
              onPressed: () {
                sl<AuthService>().logout();
              },
              child: Text(LocaleKeys.logout.tr),
            ),
          ],
        ),
      ),
    );
  }
}
