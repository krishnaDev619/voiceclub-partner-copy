import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_account_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoHomeScreenAppBar extends StatelessWidget {
  const DemoHomeScreenAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Get.to(() => const DemoAccountScreen());
            },
            child: Container(
              height: 35.0,
              width: 35.0,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.red, size: 24.0),
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 52.0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: ApplicationColors.gossip),
                ),
                child: Text(
                  LocaleKeys.demoAppTitle.tr,
                  style: TextStyle(
                    color: ApplicationColors.gossip,
                    fontSize: FontSize.L,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.white,
                  size: 16.0,
                ),
                const SizedBox(width: 6.0),
                Text(LocaleKeys.demoHelp.tr, style: TextStyles.h3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
