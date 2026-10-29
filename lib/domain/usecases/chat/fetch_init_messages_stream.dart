import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class FetchInitMessagesStreamUsecase
    implements
        UseCase<
          Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>,
          FetchInitMessagesStreamParams
        > {
  final ChatRepository _chatRepository;

  FetchInitMessagesStreamUsecase(this._chatRepository);

  @override
  Future<Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>> call(
    FetchInitMessagesStreamParams params,
  ) async {
    return _chatRepository.fetchInitMessagesStream(
      chatGroupId: params.chatGroupId,
      limit: params.limit,
    );
  }
}

class FetchInitMessagesStreamParams extends Equatable {
  final int chatGroupId;
  final int? limit;

  const FetchInitMessagesStreamParams({
    required this.chatGroupId,
    required this.limit,
  });

  @override
  List<Object?> get props => [chatGroupId, limit];
}
