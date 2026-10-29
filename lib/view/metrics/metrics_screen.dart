import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/probation_course_service.dart';
import 'package:voiceclub_partner/modules/controller/probation_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/metrics/widgets/metrics_history.dart';
import 'package:voiceclub_partner/view/metrics/widgets/metrics_meter_widget.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/view/widgets/play_video_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  final controller = Get.find<ProbationController>();
  final userController = Get.find<UserController>();

  @override
  initState() {
    super.initState();
    if (userController.userDetails.value.currentStage ==
        PartnerCurrentStatus.PROBATION) {
      sl<ProbationCourseService>().getMetricIntroVideoPlayed().then((
        value,
      ) async {
        final aggregate = controller.metricsData.value.aggregate;
        if (!value &&
            aggregate != null &&
            aggregate.videoUrl != null &&
            aggregate.videoUrl!.isNotEmpty) {
          await Get.to(
            () => PlayVideoScreen(
              videoUrl: aggregate.videoUrl!,
              isMetricFlow: true,
            ),
          );
          await sl<ProbationCourseService>().setMetricIntroVideoPlayed(
            hasPlayed: true,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final aggregate = controller.metricsData.value.aggregate;

      return Scaffold(
        appBar: CustomAppBar(
          title: "",
          action: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              spacing: 8.0,
              children: [
                OutlinedButton(
                  onPressed:
                      () => Get.bottomSheet(const MetricsHistoryBottomSheet()),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    side: BorderSide(color: Get.theme.primaryColor),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 0,
                    ),
                    minimumSize: Size(70.0, 30.0),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "History",
                        style: TextStyles.h3.copyWith(
                          color: Get.theme.primaryColor,
                        ),
                      ),
                      SizedBox(width: 2.0),
                      Icon(
                        Icons.history,
                        size: 18.0,
                        color: Get.theme.primaryColor,
                      ),
                    ],
                  ),
                ),
                if (aggregate != null &&
                    aggregate.videoUrl != null &&
                    aggregate.videoUrl!.isNotEmpty)
                  OutlinedButton(
                    onPressed: () {
                      sl<AnalyticsService>().trackEvent(
                        "onescoreWatchVideoButtonClick",
                      );
                      Get.to(
                        () => PlayVideoScreen(
                          videoUrl: aggregate.videoUrl ?? '',
                          trackWatchDurationEvent: true,
                          isMetricFlow: true,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      backgroundColor: Get.theme.primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 0,
                      ),
                      minimumSize: Size(90.0, 30.0),
                    ),
                    child: Row(
                      children: [
                        Text(
                          LocaleKeys.liveWatchVideo.tr,
                          style: TextStyles.h3,
                        ),
                        SizedBox(width: 2.0),
                        Icon(
                          Icons.play_arrow,
                          size: 16.0,
                          color: ApplicationColors.white,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        body: const MetricsMeterWidget(),
      );
    });
  }
}
