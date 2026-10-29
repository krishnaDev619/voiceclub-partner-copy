import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/string_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/features/onboarding/core/injection_container.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/analytics_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/facebook_event_service.dart';
import 'package:voiceclub_partner/features/onboarding/core/services/video_service.dart';
import 'package:voiceclub_partner/features/onboarding/modules/controllers/default_video_controller.dart';
import 'package:voiceclub_partner/features/onboarding/views/video_screen/testimonial_video_screen.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:video_player/video_player.dart';

class MeetingOneVideoScreen extends StatefulWidget {
  const MeetingOneVideoScreen({super.key});

  @override
  State<MeetingOneVideoScreen> createState() => _MeetingOneVideoScreenState();
}

class _MeetingOneVideoScreenState extends State<MeetingOneVideoScreen> {
  final url = URLConstants.meetingOneVideo;
  late DefaultVideoController controller;

  @override
  void initState() {
    controller = Get.put(DefaultVideoController(url: url), tag: url);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkVideoSeen(controller);
    });
    sl<AnalyticsService>().trackEvent("introVideoScreen");
    FacebookEventService.trackLead(value: 10);
    sl<AnalyticsService>().firebaseAnalytics.logLogin();
    super.initState();
  }

  void checkVideoSeen(DefaultVideoController controller) async {
    bool isSeen = await sl<VideoService>().getMeetingOneVideoSeen();
    controller.isBtnEnabled.value = isSeen;
    controller.update();
  }

  void setVideoSeen() async {
    await sl<VideoService>().setMeetingOneVideoSeen();
  }

  void goToTestimonialVideoScreen() {
    Get.to(() => const TestimonialVideoScreen());
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Obx(() {
            return Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: 100.0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0.0, 0.5, 1.0],
                          colors: [
                            Color(0xFF413556),
                            Color(0xFF4E316C),
                            Color(0xFF413556),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: VideoPlayer(controller.videoPlayerController),
                    ),
                  ],
                ),
                Container(
                  height: 100.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 1.0),
                        Colors.black.withValues(alpha: 0.7),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 100.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        end: Alignment.topCenter,
                        begin: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 1.0),
                          Colors.black.withValues(alpha: 0.7),
                          Colors.black.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 4.0),
                      Text(
                        LocaleKeys.welcomeToVoiceClubPartner.tr,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () {
                                controller.playOrPauseVideo("m1VideoScreen");
                              },
                              child: Icon(
                                controller.isVideoPlaying.value
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              controller.reverseFiveSeconds();
                              sl<AnalyticsService>().trackEvent(
                                "rewindVideo",
                                eventProperties: {
                                  "screenName": "m1VideoScreen",
                                },
                              );
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.keyboard_double_arrow_left),
                                Text(
                                  "5 secs",
                                  style: TextStyle(fontWeight: Weight.heavy),
                                ),
                              ],
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: controller.videoPlayerController,
                            builder: (context, VideoPlayerValue value, child) {
                              return Text(
                                controller.getRemainingTime(value.position),
                                style: const TextStyle(
                                  fontWeight: Weight.heavy,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                        child: VideoProgressIndicator(
                          key: Key(
                            "${controller.videoPlayerController.hashCode}",
                          ),
                          controller.videoPlayerController,
                          allowScrubbing: controller.isBtnEnabled.value,
                          colors: VideoProgressColors(
                            playedColor: Get.theme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        height: 50,
                        child: CustomButton(
                          text: LocaleKeys.continueLabel.tr,
                          enabled:
                              StringConstants.isDev
                                  ? true
                                  : controller.isBtnEnabled.value,
                          onTap: () async {
                            setVideoSeen();
                            FacebookEventService.trackViewContent(value: 10);
                            sl<AnalyticsService>().firebaseAnalytics
                                .logSelectContent(
                                  contentType: "introVideoScreenContinue",
                                  itemId: "123",
                                );
                            await sl<AnalyticsService>().mixpanel.track(
                              "introVideoScreenContinue",
                            );
                            await controller.checkAndPauseVideo();
                            goToTestimonialVideoScreen();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
