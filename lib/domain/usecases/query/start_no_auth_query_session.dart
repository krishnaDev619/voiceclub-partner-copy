import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/query/start_session_response_model.dart';
import 'package:voiceclub_partner/domain/repository/no_auth_query_repository.dart';

class StartNoAuthQuerySessionUseCase {
  final NoAuthQueryRepository _repository;

  StartNoAuthQuerySessionUseCase(this._repository);

  Future<DataState<StartSessionResponseModel>> call({
    required String source,
    required int accountId,
  }) {
    return _repository.startSession(source: source, accountId: accountId);
  }
}
