import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/domain/repository/no_auth_query_repository.dart';

class SendNoAuthQueryMessageUseCase {
  final NoAuthQueryRepository _repository;

  SendNoAuthQueryMessageUseCase(this._repository);

  Future<DataState<void>> call({
    required String sessionId,
    required String content,
    required int accountId,
  }) {
    return _repository.sendMessage(
      sessionId: sessionId,
      content: content,
      accountId: accountId,
    );
  }
}
