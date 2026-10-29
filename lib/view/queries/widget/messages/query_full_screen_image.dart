import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class QueryFullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String? title;

  const QueryFullScreenImage({super.key, required this.imageUrl, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
            title != null
                ? Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
                : null,
      ),
      body: Hero(
        tag: imageUrl,
        child: PhotoView(
          imageProvider: FastCachedImageProvider(imageUrl),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          loadingBuilder:
              (context, event) => Center(
                child: CircularProgressIndicator(
                  value:
                      event == null
                          ? null
                          : event.cumulativeBytesLoaded /
                              (event.expectedTotalBytes ?? 1),
                  color: Colors.white,
                ),
              ),
          errorBuilder:
              (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48.0,
                ),
              ),
        ),
      ),
    );
  }
}
