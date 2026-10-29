import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';

class VideoScreenTile extends StatelessWidget {
  final String? thumbnail;
  const VideoScreenTile({super.key, required this.thumbnail});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.0,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        image:
            thumbnail != null
                ? DecorationImage(
                  image: FastCachedImageProvider(thumbnail ?? ""),
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(
                    Colors.black38,
                    BlendMode.darken,
                  ),
                )
                : const DecorationImage(
                  image: AssetImage(AssetConstants.videoThumbnail),
                  fit: BoxFit.cover,
                ),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_rounded, color: Colors.white, size: 50.0),
      ),
    );
  }
}
