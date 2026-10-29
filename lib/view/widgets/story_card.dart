import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:voiceclub_partner/modules/controller/story_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/story/create_story_screen.dart';
import 'package:voiceclub_partner/view/story/story_view_screen.dart';
import 'package:voiceclub_partner/view/story/video_story_view_screen.dart';

class StoryCard extends StatelessWidget {
  StoryCard({super.key});

  final userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StoryController>(
      builder: (controller) {
        bool hasStory = controller.hasStory.value;
        return Container(
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 5,
                spreadRadius: 1,
                color: const Color(0xffFE9E4A).withValues(alpha: 0.1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        hasStory
                            ? (controller.seen.value
                                ? Colors.grey
                                : Get.theme.primaryColor)
                            : Colors.white,
                    width: 2.0,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Get.theme.primaryColor,
                  backgroundImage: FastCachedImageProvider(
                    userController.userDetails.value.user?.avatar ?? '',
                  ),
                  radius: 20.0,
                ),
              ),
              const SizedBox(width: 8.0),
              const Text(
                'My Story',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              controller.isLoading.value
                  ? SizedBox(
                    height: 16.0,
                    width: 16.0,
                    child: CircularProgressIndicator(
                      color: Get.theme.primaryColor,
                      strokeWidth: 2.0,
                    ),
                  )
                  : OutlinedButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 8.0,
                        ),
                      ),
                      side: WidgetStateProperty.all(
                        BorderSide(color: Get.theme.primaryColor, width: 1.5),
                      ),
                    ),
                    onPressed: () async {
                      if (hasStory) {
                        if (controller.storyData.value.story?.mediaType ==
                            "VIDEO") {
                          final videoFile = File(controller.path.value);
                          final videoPlayerController =
                              VideoPlayerController.file(videoFile);
                          await videoPlayerController.initialize();
                          final durationInMilliSeconds =
                              videoPlayerController
                                  .value
                                  .duration
                                  .inMilliseconds;
                          Get.to(
                            VideoStoryViewScreen(
                              videoPlayerController: videoPlayerController,
                              durationInMilliseconds: durationInMilliSeconds,
                            ),
                          );
                        } else {
                          final audioPlayerController = PlayerController();
                          const playerWaveStyle = PlayerWaveStyle(
                            fixedWaveColor: Colors.white54,
                            liveWaveColor: Colors.white,
                            spacing: 6,
                          );
                          await audioPlayerController
                              .preparePlayer(
                                path: controller.path.value,
                                shouldExtractWaveform: true,
                                noOfSamples: playerWaveStyle.getSamplesForWidth(
                                  MediaQuery.of(context).size.width - 180.0,
                                ),
                              )
                              .then((_) async {
                                audioPlayerController.setFinishMode(
                                  finishMode: FinishMode.pause,
                                );
                                final durationInMilliseconds =
                                    await audioPlayerController.getDuration();
                                Get.to(
                                  () => StoryViewScreen(
                                    width: MediaQuery.of(context).size.width,
                                    audioPlayerController:
                                        audioPlayerController,
                                    durationInMilliseconds:
                                        durationInMilliseconds,
                                  ),
                                );
                              });
                        }
                      } else {
                        Get.to(() => const CreateStoryScreen());
                      }
                    },
                    child: Text(
                      hasStory ? 'View' : '+ Add New Story',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
