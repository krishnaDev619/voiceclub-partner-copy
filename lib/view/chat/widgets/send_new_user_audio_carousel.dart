import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/modules/controller/multi_reward_controller.dart';
import 'package:voiceclub_partner/view/chat/widgets/send_new_user_audio_container.dart';

class SendNewUserAudioCarousel extends StatelessWidget {
  final bool isHomeScreen;
  const SendNewUserAudioCarousel({super.key, required this.isHomeScreen});

  @override
  Widget build(BuildContext context) {
    final chatOverviewController = Get.find<ChatOverviewController>();
    final carouselController = CarouselSliderController();
    return Obx(() {
      return Visibility(
        visible: chatOverviewController.pendingAudios.isNotEmpty,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom:
                  (Get.find<MultiRewardController>().isRewardActive &&
                          !isHomeScreen)
                      ? 36.0
                      : 0.0,
            ),
            child: CarouselSlider(
              items:
                  chatOverviewController.pendingAudios
                      .map(
                        (audio) => SendNewUserAudioContainer(
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
        ),
      );
    });
  }
}
