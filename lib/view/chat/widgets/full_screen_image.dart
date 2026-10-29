import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String? name;

  const FullScreenImage({super.key, required this.imageUrl, this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title:
            (name?.isNotEmpty ?? false)
                ? Text(
                  name ?? "Profile Picture",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
                : null,
        actions: [
          GestureDetector(
            child: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.close, color: Colors.white),
            ),
            onTap: () {
              Get.back(); // Close the full-screen image;
            },
          ),
        ],
      ),
      body: PhotoView(
        imageProvider: FastCachedImageProvider(
          imageUrl,
        ), // Load the image from a URL
        backgroundDecoration: const BoxDecoration(
          color: Colors.black, // Background color of the full-screen view
        ),
        minScale:
            PhotoViewComputedScale.contained, // Set the minimum zoom scale
        maxScale: PhotoViewComputedScale.covered, // Set the maximum zoom scale
      ),
    );
  }
}
