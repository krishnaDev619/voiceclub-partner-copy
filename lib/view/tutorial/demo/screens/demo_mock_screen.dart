import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoMockScreen extends StatelessWidget {
  const DemoMockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(LocaleKeys.demoStage1Mock.tr)));
  }
}
