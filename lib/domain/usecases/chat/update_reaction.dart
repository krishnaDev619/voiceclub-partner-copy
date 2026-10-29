import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class UpdateReactionUseCase implements UseCase<void, UpdateReactionParams> {
  final ChatRepository _chatRepository;

  UpdateReactionUseCase(this._chatRepository);

  @override
  Future<void> call(UpdateReactionParams params) async {
    return _chatRepository.updateReaction(
      chatGroupId: params.chatGroupId,
      documentId: params.documentId,
      reaction: params.reaction,
    );
  }
}

class UpdateReactionParams extends Equatable {
  final int chatGroupId;
  final String documentId;
  final String reaction;

  const UpdateReactionParams({
    required this.chatGroupId,
    required this.documentId,
    required this.reaction,
  });

  @override
  List<Object?> get props => [chatGroupId, documentId];
}
