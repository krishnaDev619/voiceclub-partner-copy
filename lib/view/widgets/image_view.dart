import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final String? imageUrl;
  const ImageView({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(elevation: 0.0, backgroundColor: Colors.white),
      body: Center(
        child: FastCachedImage(
          url: imageUrl ?? '',
          loadingBuilder: (_, _) => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
