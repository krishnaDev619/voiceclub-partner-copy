import 'package:voiceclub_partner/data/models/query/query_message_model.dart';
import 'package:voiceclub_partner/domain/repository/no_auth_query_repository.dart';

class WatchNoAuthQueryMessagesUseCase {
  final NoAuthQueryRepository _repository;

  WatchNoAuthQueryMessagesUseCase(this._repository);

  Stream<List<QueryMessageModel>> call({required String sessionId}) {
    return _repository.watchMessages(sessionId: sessionId);
  }
}
