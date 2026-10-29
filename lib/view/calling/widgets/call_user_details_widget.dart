import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';

class CallUserDetailsWidget extends StatelessWidget {
  final String name;
  final String? avatar;
  final String? customName;
  final bool isNewUser;

  const CallUserDetailsWidget({
    super.key,
    required this.name,
    required this.avatar,
    this.customName,
    this.isNewUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomProfilePicture(
          avatarURL: avatar,
          name: name,
          radius: 28.0,
          backgroundColor: const Color(0xFF64C5EE).withValues(alpha: 0.25),
          textColor: isNewUser ? Colors.white : const Color(0xFF166B90),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            "$name${(customName?.isNotEmpty ?? false) ? "\n($customName)" : ""}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isNewUser ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: GoogleFonts.mulish().fontFamily,
              fontSize: FontSize.xXL,
            ),
          ),
        ),
      ],
    );
  }
}
