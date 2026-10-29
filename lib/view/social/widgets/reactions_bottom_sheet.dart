import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/social/post_model.dart';
import 'package:voiceclub_partner/view/social/controllers/reactions_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ReactionsBottomSheet extends StatefulWidget {
  final PostModel post;

  const ReactionsBottomSheet({super.key, required this.post});

  @override
  State<ReactionsBottomSheet> createState() => _ReactionsBottomSheetState();
}

class _ReactionsBottomSheetState extends State<ReactionsBottomSheet> {
  late final ReactionsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ReactionsController(postId: widget.post.id!));
    sl<AnalyticsService>().trackEvent(
      "viewReactions",
      eventProperties: {
        "postId": widget.post.id,
        "postType": widget.post.postType?.name,
        "postUser": widget.post.user?.name,
        "postUserRole": widget.post.user?.role?.name,
        "postUserPhone": widget.post.user?.phoneNumber,
        "postCaption": widget.post.caption,
        "postText": widget.post.textOverlay,
        "reactionCount": widget.post.reactionCounts?.toJson(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                  "Reactions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            // Reaction tabs
            Obx(() {
              final availableReactions = _getFilteredReactionTypes(controller);
              if (availableReactions.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children:
                      ReactionType.values.map((reactionType) {
                        final isSelected =
                            controller.selectedReactionType.value ==
                            reactionType;

                        return Expanded(
                          child: GestureDetector(
                            onTap:
                                () =>
                                    controller.selectReactionType(reactionType),
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom:
                                      isSelected
                                          ? BorderSide(
                                            color: Get.theme.primaryColor,
                                            width: 3.0,
                                          )
                                          : BorderSide.none,
                                ),
                              ),
                              child: Text(
                                reactionType.emoji,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              );
            }),
            // Divider
            Transform.translate(
              offset: const Offset(0, -8),
              child: Divider(height: 1, color: Colors.grey.shade300),
            ),
            // List of users
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.hasError.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Could not load ${controller.selectedReactionType.value.name.toLowerCase()} reactions',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.selectedReactionType.value.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No ${controller.selectedReactionType.value.name.toLowerCase()} reactions yet',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: controller.users.length,
                  itemBuilder: (context, index) {
                    final user = controller.users[index];
                    return ListTile(
                      dense: true,
                      leading: CustomProfilePicture(
                        avatarURL: user.avatar,
                        name: user.name ?? 'Anonymous',
                        radius: 18,
                      ),
                      title: Text(
                        user.name ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      trailing: Text(
                        controller.selectedReactionType.value.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<ReactionType> _getFilteredReactionTypes(ReactionsController controller) {
    // Show all reaction types that have at least one reaction
    final availableTypes =
        ReactionType.values.where((type) {
          final count = controller.reactionCounts[type] ?? 0;
          return count > 0;
        }).toList();

    // If no reactions yet, show the default LIKE tab
    if (availableTypes.isEmpty) {
      return [ReactionType.LIKE];
    }

    return availableTypes;
  }
}
