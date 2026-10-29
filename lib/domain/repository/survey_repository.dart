import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/survey/user_survey_submissions_model.dart';

abstract class SurveyRepository {
  Future<DataState<bool>> hasUserSubmittedSurvey({
    required String userId,
    required String surveyId,
  });

  Future<DataState<void>> markSurveyAsSubmitted({
    required String userId,
    required String surveyId,
  });

  Future<DataState<List<String>>> getUserSubmittedSurveys({
    required String userId,
  });

  Future<DataState<UserSurveySubmissionsModel?>> getUserSurveySubmissions({
    required String userId,
  });
}
