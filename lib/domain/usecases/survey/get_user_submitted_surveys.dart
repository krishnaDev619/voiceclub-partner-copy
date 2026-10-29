import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/survey_repository.dart';

class GetUserSubmittedSurveys
    implements UseCase<DataState<List<String>>, GetUserSubmittedSurveysParams> {
  final SurveyRepository _surveyRepository;

  GetUserSubmittedSurveys(this._surveyRepository);

  @override
  Future<DataState<List<String>>> call(
    GetUserSubmittedSurveysParams params,
  ) async {
    return _surveyRepository.getUserSubmittedSurveys(userId: params.userId);
  }
}

class GetUserSubmittedSurveysParams {
  final String userId;

  GetUserSubmittedSurveysParams({required this.userId});
}
