import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';

class CommentItemShimmer extends StatelessWidget {
  const CommentItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile picture shimmer
          ShimmerCustom(
            child: CustomProfilePicture(
              avatarURL: "",
              name: "N",
              radius: 15,
              backgroundColor: Get.theme.primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and time shimmer
                const ShimmerContainer(
                  height: 12.0,
                  width: 80.0,
                  borderRadius: 4.0,
                ),
                const SizedBox(height: 2),
                // Comment text shimmer
                const ShimmerContainer(
                  height: 12.0,
                  width: double.infinity,
                  borderRadius: 4.0,
                ),
                const SizedBox(height: 4),
                // Reply button shimmer
                Text(
                  'Reply',
                  style: TextStyle(
                    color: Colors.grey[300]!,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Like button and count shimmer
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 2),
              ShimmerCustom(
                child: Icon(
                  Icons.favorite_border,
                  size: 16,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 4),
              const ShimmerContainer(
                height: 10.0,
                width: 12.0,
                borderRadius: 4.0,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
