import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class DeleteChatMessageUsecase
    implements UseCase<void, DeleteChatMessageParams> {
  final ChatRepository _chatRepository;

  DeleteChatMessageUsecase(this._chatRepository);

  @override
  Future<void> call(DeleteChatMessageParams params) async {
    return _chatRepository.deleteChatMessage(
      chatGroupId: params.chatGroupId,
      documentId: params.documentId,
    );
  }
}

class DeleteChatMessageParams extends Equatable {
  final int chatGroupId;
  final String documentId;

  const DeleteChatMessageParams({
    required this.chatGroupId,
    required this.documentId,
  });

  @override
  List<Object?> get props => [chatGroupId, documentId];
}
