import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';

class PostCardShimmer extends StatelessWidget {
  const PostCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User profile section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      ShimmerCustom(
                        child: CustomProfilePicture(
                          avatarURL: "",
                          name: "N",
                          radius: 16.0,
                          backgroundColor: Get.theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerContainer(
                            height: 13.0,
                            width: 100.0,
                            borderRadius: 4.0,
                          ),
                          SizedBox(height: 2),
                          ShimmerContainer(
                            height: 10.0,
                            width: 60.0,
                            borderRadius: 4.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Text content shimmer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerContainer(
                  height: 14.0,
                  width: double.infinity,
                  borderRadius: 4.0,
                ),
                SizedBox(height: 4),
                ShimmerContainer(height: 14.0, width: 200.0, borderRadius: 4.0),
              ],
            ),
          ),

          // Media content shimmer
          Center(child: ShimmerContainer(width: Get.width, height: Get.width)),

          // Like and comment section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border),
                      color: Colors.grey[300]!,
                      onPressed: null,
                      visualDensity: VisualDensity.compact,
                    ),
                    const ShimmerContainer(
                      height: 14.0,
                      width: 20.0,
                      borderRadius: 4.0,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.mode_comment_outlined),
                      color: Colors.grey[300]!,
                      visualDensity: VisualDensity.compact,
                      onPressed: null,
                    ),
                    const ShimmerContainer(
                      height: 14.0,
                      width: 20.0,
                      borderRadius: 4.0,
                    ),
                  ],
                ),

                // Most relevant comment shimmer
                const Padding(
                  padding: EdgeInsets.only(left: 6, top: 4),
                  child: Row(
                    children: [
                      ShimmerContainer(
                        height: 14.0,
                        width: 80.0,
                        borderRadius: 4.0,
                      ),
                      SizedBox(width: 4),
                      ShimmerContainer(
                        height: 14.0,
                        width: 120.0,
                        borderRadius: 4.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
