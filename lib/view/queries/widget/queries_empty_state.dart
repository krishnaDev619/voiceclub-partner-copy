import 'package:flutter/material.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class QueriesEmptyState extends StatelessWidget {
  final VoidCallback? onAddQueryTap;

  const QueriesEmptyState({super.key, this.onAddQueryTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 100.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_queries.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 32.0),
            CustomButton(
              text: LocaleKeys.liveAddANewQuery.tr,
              onTap: onAddQueryTap,
              width: Get.width / 1.5,
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
              color: const Color(0xFFEE6464),
            ),
          ],
        ),
      ),
    );
  }
}
