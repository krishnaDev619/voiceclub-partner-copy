import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/metrics/metrics_api_service.dart';
import 'package:voiceclub_partner/data/models/metrics/get_metrics_score.dart';
import 'package:voiceclub_partner/data/models/metrics/get_probation_details_response.dart';
import 'package:voiceclub_partner/domain/repository/probation_repository.dart';

class MetricsRepositoryImpl implements MetricsRepository {
  final MetricsApiService _probationApiService;

  MetricsRepositoryImpl(this._probationApiService);

  @override
  Future<DataState<GetProbationDetailsResponseModel>>
  getProbationDetails() async {
    try {
      final response = await _probationApiService.getProbationDetails();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState> markProbationCourseCompleted() async {
    try {
      final response =
          await _probationApiService.markProbationCourseCompleted();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetMetricsScoreResponse>> getMetricsScore({
    bool scoreOnly = false,
  }) async {
    try {
      final response = await _probationApiService.getMetricsScore(
        scoreOnly: scoreOnly,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
