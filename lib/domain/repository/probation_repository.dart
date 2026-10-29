import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/metrics/get_metrics_score.dart';
import 'package:voiceclub_partner/data/models/metrics/get_probation_details_response.dart';

abstract class MetricsRepository {
  Future<DataState<GetProbationDetailsResponseModel>> getProbationDetails();

  Future<DataState> markProbationCourseCompleted();

  Future<DataState<GetMetricsScoreResponse>> getMetricsScore({bool scoreOnly});
}
