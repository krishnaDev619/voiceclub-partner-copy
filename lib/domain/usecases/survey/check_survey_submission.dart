import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/survey_repository.dart';

class CheckSurveySubmission
    implements UseCase<DataState<bool>, CheckSurveySubmissionParams> {
  final SurveyRepository _surveyRepository;

  CheckSurveySubmission(this._surveyRepository);

  @override
  Future<DataState<bool>> call(CheckSurveySubmissionParams params) async {
    return _surveyRepository.hasUserSubmittedSurvey(
      userId: params.userId,
      surveyId: params.surveyId,
    );
  }
}

class CheckSurveySubmissionParams {
  final String userId;
  final String surveyId;

  CheckSurveySubmissionParams({required this.userId, required this.surveyId});
}
