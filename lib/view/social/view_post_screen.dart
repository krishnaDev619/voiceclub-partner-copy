import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/view/social/controllers/view_post_controller.dart';
import 'package:voiceclub_partner/view/social/widgets/post_card.dart';
import 'package:voiceclub_partner/view/social/widgets/post_card_shimmer.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ViewPostScreen extends StatefulWidget {
  final String postId;

  const ViewPostScreen({super.key, required this.postId});

  @override
  State<ViewPostScreen> createState() => _ViewPostScreenState();
}

class _ViewPostScreenState extends State<ViewPostScreen> {
  late ViewPostController _controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<ViewPostController>(tag: widget.postId)) {
      _controller = Get.find<ViewPostController>(tag: widget.postId);
    } else {
      _controller = Get.put(
        ViewPostController(postId: widget.postId),
        tag: widget.postId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          LocaleKeys.livePost.tr,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading) {
          return const Center(child: PostCardShimmer());
        }

        if (_controller.error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _controller.error,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.fetchPost(),
                  child: Text(LocaleKeys.tryAgain.tr),
                ),
              ],
            ),
          );
        }

        final postState = _controller.postState;
        if (postState == null) {
          return const SizedBox.shrink();
        }

        if (postState is DataFailed) {
          return Center(
            child: Text(
              postState.error?.message ?? 'Failed to load post',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (postState is DataSuccess) {
          final post = postState.data?.post;
          if (post == null) {
            return Center(child: Text(LocaleKeys.livePostNotFound.tr));
          }

          return SingleChildScrollView(
            child: PostCard(post: post, isViewPost: true),
          );
        }

        return const SizedBox.shrink();
      }),
    );
  }
}
