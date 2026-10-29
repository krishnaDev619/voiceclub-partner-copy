import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';

class ChatProfilePicture extends StatelessWidget {
  final ChatMember? person;

  const ChatProfilePicture({super.key, this.person});

  void _showAvatarDialog(BuildContext context, String? avatar) {
    Get.dialog(
      Dialog(
        shape: const CircleBorder(),
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10.0),
        child: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: FastCachedImageProvider(
                  avatar ?? AvatarService.getRandomAvatarUrl(),
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = person?.user?.avatar;
    if (avatar?.isEmpty ?? true) {
      return Container(
        width: 32.0,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Get.theme.primaryColor,
          border: Border.all(color: Colors.white),
        ),
        child: FittedBox(
          child: Text(
            AvatarService.getAvatarInitials(person?.user?.name),
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
              fontFamily: GoogleFonts.mulish().fontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          _showAvatarDialog(context, avatar);
        },
        child: Container(
          width: 32.0,
          height: 32.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Get.theme.primaryColor,
            image: DecorationImage(
              image: FastCachedImageProvider(
                avatar ?? AvatarService.getRandomAvatarUrl(),
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
  }
}
