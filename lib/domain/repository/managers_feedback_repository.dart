import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/managers_feedback/get_managers_feedback_response.dart';
import 'package:voiceclub_partner/data/models/managers_feedback/update_feedback_response.dart';

abstract class ManagersFeedbackRepository {
  Future<DataState<GetManagersFeedbackResponseModel>> getManagersFeedback({
    int? page,
    int? pageSize,
  });

  Future<DataState<UpdateFeedbackResponseModel>> updateManagersFeedbackStatus({
    required int id,
    required bool addressed,
  });
}
