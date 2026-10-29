import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/view/social/controllers/likes_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class LikesBottomSheet extends StatelessWidget {
  final String postId;

  const LikesBottomSheet({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LikesController(postId: postId));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Container(
            padding: const EdgeInsets.only(top: 14, bottom: 6),
            child: const Center(
              child: Text(
                "Likes",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          // List of users
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.users.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.hasError.value && controller.users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Could not load likes',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: controller.retry,
                        child: Text(LocaleKeys.liveRetry.tr),
                      ),
                    ],
                  ),
                );
              }

              if (controller.users.isEmpty) {
                return const Center(
                  child: Text(
                    'No likes yet',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      !controller.isLoading.value &&
                      controller.hasMore.value) {
                    controller.fetchLikes();
                  }
                  return true;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 4),
                  itemCount:
                      controller.users.length +
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= controller.users.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final user = controller.users[index];
                    return ListTile(
                      dense: true,
                      leading: CustomProfilePicture(
                        avatarURL: user.avatar,
                        name: user.name ?? 'Anonymous',
                        radius: 16,
                      ),
                      title: Text(
                        user.name ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.favorite,
                        size: 14,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
