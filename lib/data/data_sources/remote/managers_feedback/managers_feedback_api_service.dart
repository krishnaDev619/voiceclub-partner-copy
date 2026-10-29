import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/managers_feedback/get_managers_feedback_response.dart';
import 'package:voiceclub_partner/data/models/managers_feedback/update_feedback_response.dart';

part 'managers_feedback_api_service.g.dart';

@RestApi()
abstract class ManagersFeedbackApiService {
  factory ManagersFeedbackApiService(Dio dio) = _ManagersFeedbackApiService;

  @GET(APIConstants.getManagersFeedbackRoute)
  Future<HttpResponse<GetManagersFeedbackResponseModel>> getManagersFeedback({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @PUT(APIConstants.updateManagersFeedbackStatusRoute)
  Future<HttpResponse<UpdateFeedbackResponseModel>>
  updateManagersFeedbackStatus({
    @Path('id') required int id,
    @Field('addressed') required bool addressed,
  });
}
