import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/data_sources/remote/survey/survey_firebase_service.dart';
import 'package:voiceclub_partner/data/models/survey/user_survey_submissions_model.dart';
import 'package:voiceclub_partner/domain/repository/survey_repository.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  final SurveyFirebaseService _surveyFirebaseService;

  SurveyRepositoryImpl(this._surveyFirebaseService);

  @override
  Future<DataState<bool>> hasUserSubmittedSurvey({
    required String userId,
    required String surveyId,
  }) async {
    try {
      final result = await _surveyFirebaseService.hasUserSubmittedSurvey(
        userId: userId,
        surveyId: surveyId,
      );
      return DataSuccess(result);
    } catch (e) {
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: ''),
          error: e.toString(),
        ),
      );
    }
  }

  @override
  Future<DataState<void>> markSurveyAsSubmitted({
    required String userId,
    required String surveyId,
  }) async {
    try {
      await _surveyFirebaseService.markSurveyAsSubmitted(
        userId: userId,
        surveyId: surveyId,
      );
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: ''),
          error: e.toString(),
        ),
      );
    }
  }

  @override
  Future<DataState<List<String>>> getUserSubmittedSurveys({
    required String userId,
  }) async {
    try {
      final result = await _surveyFirebaseService.getUserSubmittedSurveys(
        userId: userId,
      );
      return DataSuccess(result);
    } catch (e) {
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: ''),
          error: e.toString(),
        ),
      );
    }
  }

  @override
  Future<DataState<UserSurveySubmissionsModel?>> getUserSurveySubmissions({
    required String userId,
  }) async {
    try {
      final result = await _surveyFirebaseService.getUserSurveySubmissions(
        userId: userId,
      );
      return DataSuccess(result);
    } catch (e) {
      return DataFailed(
        DioException(
          requestOptions: RequestOptions(path: ''),
          error: e.toString(),
        ),
      );
    }
  }
}
