import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';

class CallLanguageWidget extends StatelessWidget {
  final String? demandLanguage;
  final bool isNewUser;

  const CallLanguageWidget({
    super.key,
    required this.demandLanguage,
    required this.isNewUser,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: demandLanguage?.isNotEmpty ?? false,
      child: Container(
        decoration: BoxDecoration(
          color: isNewUser ? const Color(0xFF948BB1) : const Color(0xFFFFE6CF),
          borderRadius: BorderRadius.circular(6.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20.0,
              width: 20.0,
              child: SvgPicture.asset(
                AssetConstants.languageIcon,
                height: 16.0,
                width: 16.0,
                colorFilter: ColorFilter.mode(
                  isNewUser ? Colors.white : Colors.black54,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              demandLanguage ?? "Hindi",
              style: TextStyle(
                color: isNewUser ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
