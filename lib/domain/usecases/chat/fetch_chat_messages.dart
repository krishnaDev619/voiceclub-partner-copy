import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class FetchChatMessagesUsecase
    implements
        UseCase<QuerySnapshot<Map<String, dynamic>>, FetchChatMessagesParams> {
  final ChatRepository _chatRepository;

  FetchChatMessagesUsecase(this._chatRepository);

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> call(
    FetchChatMessagesParams params,
  ) async {
    return _chatRepository.fetchChatMessages(
      chatGroupId: params.chatGroupId,
      lastDocument: params.lastDocument,
    );
  }
}

class FetchChatMessagesParams extends Equatable {
  final int chatGroupId;
  final QueryDocumentSnapshot lastDocument;

  const FetchChatMessagesParams({
    required this.chatGroupId,
    required this.lastDocument,
  });

  @override
  List<Object> get props => [chatGroupId, lastDocument];
}
