import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/query_repository.dart';

class FetchQueryChatMessagesStreamUseCase
    implements
        UseCase<
          Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>,
          FetchQueryChatMessagesStreamParams
        > {
  final QueryRepository _queryRepository;

  FetchQueryChatMessagesStreamUseCase(this._queryRepository);

  @override
  Future<Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>> call(
    FetchQueryChatMessagesStreamParams params,
  ) async {
    return _queryRepository.fetchQueryChatMessagesStream(
      sessionId: params.sessionId,
    );
  }
}

class FetchQueryChatMessagesStreamParams extends Equatable {
  final String sessionId;

  const FetchQueryChatMessagesStreamParams({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
