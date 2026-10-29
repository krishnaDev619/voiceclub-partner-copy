import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_send_new_user_audio_container.dart';

class DemoSendNewUserAudioCarousel extends StatelessWidget {
  const DemoSendNewUserAudioCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DemoLandingController>();
    final carouselController = CarouselSliderController();
    return Obx(() {
      return Visibility(
        visible: controller.pendingAudios.isNotEmpty,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: CarouselSlider(
            items:
                controller.pendingAudios
                    .map(
                      (audio) => DemoSendNewUserAudioContainer(
                        key: UniqueKey(),
                        pendingAudio: audio,
                      ),
                    )
                    .toList(),
            carouselController: carouselController,
            options: CarouselOptions(
              height: 120.0,
              enableInfiniteScroll: false,
              viewportFraction: 1.0,
              autoPlay: true,
            ),
          ),
        ),
      );
    });
  }
}
