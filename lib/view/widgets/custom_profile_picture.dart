import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/view/chat/widgets/full_screen_image.dart';

class CustomProfilePicture extends StatelessWidget {
  final String? avatarURL;
  final String? name;
  final double radius;
  final Color backgroundColor;
  final Color textColor;
  final bool allowTapAndZoom;

  const CustomProfilePicture({
    super.key,
    required this.avatarURL,
    required this.name,
    this.radius = 24.0,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white,
    this.allowTapAndZoom = false,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: ClipOval(
        child: GestureDetector(
          onLongPress:
              allowTapAndZoom
                  ? () {
                    if (avatarURL?.isNotEmpty ?? false) {
                      Get.to(
                        () => FullScreenImage(
                          imageUrl: avatarURL ?? "",
                          name: name,
                        ),
                        duration: Duration.zero,
                      );
                    }
                  }
                  : null,
          child: FastCachedImage(
            url: avatarURL ?? "",
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
            errorBuilder:
                (context, url, error) => Align(
                  alignment: Alignment.center,
                  child: Text(
                    AvatarService.getAvatarInitials(name),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor, fontSize: radius / 1.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
