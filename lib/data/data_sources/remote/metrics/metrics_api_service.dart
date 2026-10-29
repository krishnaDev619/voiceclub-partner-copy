import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/metrics/get_metrics_score.dart';
import 'package:voiceclub_partner/data/models/metrics/get_probation_details_response.dart';

part 'metrics_api_service.g.dart';

@RestApi()
abstract class MetricsApiService {
  factory MetricsApiService(Dio dio) = _MetricsApiService;

  @GET(APIConstants.getProbationDetailsRoute)
  Future<HttpResponse<GetProbationDetailsResponseModel>> getProbationDetails();

  @POST(APIConstants.markProbationCourseCompletedRoute)
  Future<HttpResponse> markProbationCourseCompleted();

  @GET(APIConstants.getMetricsScoreRoute)
  Future<HttpResponse<GetMetricsScoreResponse>> getMetricsScore({
    @Query('score_only') bool? scoreOnly,
  });
}
