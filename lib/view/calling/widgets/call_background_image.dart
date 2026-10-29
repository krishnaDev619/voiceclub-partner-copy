import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CallBackgroundImage extends StatelessWidget {
  final bool isAccepted;
  final String backgroundImage;
  const CallBackgroundImage({
    super.key,
    required this.isAccepted,
    required this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Visibility(
        visible: isAccepted && backgroundImage.isNotEmpty,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          height: Get.height * 0.5,
          width: Get.width,
          child: Image.asset(backgroundImage, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
