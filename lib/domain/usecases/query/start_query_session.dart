import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/query/start_session_response_model.dart';
import 'package:voiceclub_partner/domain/repository/query_repository.dart';

class StartQuerySessionUseCase
    implements
        UseCase<DataState<StartSessionResponseModel>, StartQuerySessionParams> {
  final QueryRepository _queryRepository;

  StartQuerySessionUseCase(this._queryRepository);

  @override
  Future<DataState<StartSessionResponseModel>> call(
    StartQuerySessionParams params,
  ) async {
    return _queryRepository.startQuerySession(source: params.source);
  }
}

class StartQuerySessionParams {
  final String source;

  StartQuerySessionParams({required this.source});
}
