import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/domain/repository/no_auth_query_repository.dart';

class EndNoAuthQuerySessionUseCase {
  final NoAuthQueryRepository _repository;

  EndNoAuthQuerySessionUseCase(this._repository);

  Future<DataState<void>> call({
    required String sessionId,
    required int accountId,
  }) {
    return _repository.endSession(sessionId: sessionId, accountId: accountId);
  }
}
