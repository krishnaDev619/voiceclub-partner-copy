import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/view/social/create_audio_post_screen.dart';
import 'package:voiceclub_partner/view/social/create_image_post_screen.dart';
import 'package:voiceclub_partner/view/social/create_text_post_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CreatePostSheet extends StatelessWidget {
  const CreatePostSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline_rounded, fill: 0.0),
                  SizedBox(width: 4),
                  Text(
                    'Create your own post',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PostTypeOption(
                    icon: Icons.text_fields,
                    title: LocaleKeys.liveText.tr,
                    color: Colors.blue,
                    onTap: () {
                      Get.back();
                      Get.to(() => const CreateTextPostScreen());
                    },
                  ),
                  _PostTypeOption(
                    icon: Icons.image,
                    title: LocaleKeys.liveImage.tr,
                    color: Colors.green,
                    onTap: () {
                      Get.back();
                      Get.to(() => const CreateImagePostScreen());
                    },
                  ),
                  _PostTypeOption(
                    icon: Icons.mic,
                    title: LocaleKeys.liveAudio.tr,
                    color: Colors.purple,
                    onTap: () {
                      Get.back();
                      Get.to(() => const CreateAudioPostScreen());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _PostTypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _PostTypeOption({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
