import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/metrics/get_probation_details_response.dart';
import 'package:voiceclub_partner/domain/repository/probation_repository.dart';

class GetProbationDetailsUsecase
    implements UseCase<DataState<GetProbationDetailsResponseModel>, NoParams> {
  final MetricsRepository _probationRepository;

  GetProbationDetailsUsecase(this._probationRepository);

  @override
  Future<DataState<GetProbationDetailsResponseModel>> call(NoParams params) {
    return _probationRepository.getProbationDetails();
  }
}
