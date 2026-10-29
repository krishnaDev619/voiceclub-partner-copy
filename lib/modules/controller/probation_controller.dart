import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/metrics/get_metrics_score.dart';
import 'package:voiceclub_partner/data/models/metrics/get_probation_details_response.dart';
import 'package:voiceclub_partner/domain/usecases/metrics/get_metrics_score.dart';
import 'package:voiceclub_partner/domain/usecases/metrics/get_probation_details.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';

class ProbationController extends GetxController {
  final GetProbationDetailsResponseModel initProbationData;

  ProbationController({required this.initProbationData});

  final probationDetails = GetProbationDetailsResponseModel().obs;
  final _getProbationDetailsUsecase = sl<GetProbationDetailsUsecase>();

  // Metrics
  final metricsData = GetMetricsScoreResponse().obs;

  int get getCurrentScore {
    return metricsData.value.aggregate?.score?.toInt() ?? 0;
  }

  @override
  void onInit() {
    super.onInit();
    probationDetails.value = initProbationData;
  }

  Future<void> fetchProbationDetails({
    bool fetchMetrics = false,
    bool fireEvent = false,
    required bool scoreOnly,
  }) async {
    try {
      if (fireEvent) {
        Get.context?.loaderOverlay.show();
      }
      final result = await _getProbationDetailsUsecase.call(NoParams());
      if (result.data != null &&
          result.data?.stage != null &&
          result.data?.stage != PartnerCurrentStatus.NULL) {
        probationDetails.value = result.data!;
        final partnerCurrentStatus = probationDetails.value.stage!;
        Get.find<UserController>().partnerStatus.value = partnerCurrentStatus;
        sl<AnalyticsService>().updateProbationStatus(partnerCurrentStatus);
      }
      if (fetchMetrics) {
        await fetchMetricsData(scoreOnly: scoreOnly);
      }
    } catch (e) {
      Logger.logMessage(
        'Error fetching probation details error: $e',
        name: 'probation_controller',
      );
      // Optionally handle any exceptions here
    } finally {
      if (fireEvent) {
        Get.context?.loaderOverlay.hide();
      }
      if (fireEvent) {
        Get.context?.loaderOverlay.hide();
        sl<AnalyticsService>().trackEvent(
          'partnerMetrics',
          eventProperties: {
            'stage': probationDetails.value.stage?.name,
            if (probationDetails.value.stage == PartnerCurrentStatus.LIVE ||
                probationDetails.value.stage == PartnerCurrentStatus.NEW_LIVE ||
                probationDetails.value.stage == PartnerCurrentStatus.PROBATION)
              ...metricsData.value.scoreValues,
            if (probationDetails.value.stage == PartnerCurrentStatus.LIVE ||
                probationDetails.value.stage == PartnerCurrentStatus.NEW_LIVE ||
                probationDetails.value.stage == PartnerCurrentStatus.PROBATION)
              'oneScore': metricsData.value.aggregate?.score?.toInt(),
          },
        );
        if ((probationDetails.value.stage == PartnerCurrentStatus.LIVE ||
                probationDetails.value.stage == PartnerCurrentStatus.NEW_LIVE ||
                probationDetails.value.stage ==
                    PartnerCurrentStatus.PROBATION) &&
            metricsData.value.aggregate?.score != null) {
          sl<AnalyticsService>().updateOneScore(
            metricsData.value.aggregate!.score!.toInt(),
          );
        }
      }
    }
  }

  Future<void> fetchMetricsData({required bool scoreOnly}) async {
    try {
      final response = await sl<GetMetricsScoreUseCase>().call(
        GetMetricsScoreParams(scoreOnly: scoreOnly),
      );
      if (response.data != null) {
        metricsData.value = response.data ?? GetMetricsScoreResponse();
      }
    } catch (e) {
      Logger.logMessage("Error fetchMetricsData: ${e.toString()}");
    }
  }

  num getFireCutoffWholeValue() {
    return metricsData.value.firingCutoff ?? 0.0;
  }
}
