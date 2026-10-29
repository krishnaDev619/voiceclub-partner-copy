import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/managers_feedback/managers_feedback_api_service.dart';
import 'package:voiceclub_partner/data/models/managers_feedback/get_managers_feedback_response.dart';
import 'package:voiceclub_partner/data/models/managers_feedback/update_feedback_response.dart';
import 'package:voiceclub_partner/domain/repository/managers_feedback_repository.dart';

class ManagersFeedbackRepositoryImpl implements ManagersFeedbackRepository {
  final ManagersFeedbackApiService _managersFeedbackApiService;

  ManagersFeedbackRepositoryImpl(this._managersFeedbackApiService);

  @override
  Future<DataState<GetManagersFeedbackResponseModel>> getManagersFeedback({
    int? page,
    int? pageSize,
  }) async {
    try {
      final response = await _managersFeedbackApiService.getManagersFeedback(
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UpdateFeedbackResponseModel>> updateManagersFeedbackStatus({
    required int id,
    required bool addressed,
  }) async {
    try {
      final response = await _managersFeedbackApiService
          .updateManagersFeedbackStatus(id: id, addressed: addressed);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
