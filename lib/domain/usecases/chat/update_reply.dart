import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/chat_reply_message.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class UpdateReplyUseCase implements UseCase<void, UpdateReplyParams> {
  final ChatRepository _chatRepository;

  UpdateReplyUseCase(this._chatRepository);

  @override
  Future<void> call(UpdateReplyParams params) async {
    return _chatRepository.updateReply(
      chatGroupId: params.chatGroupId,
      documentId: params.documentId,
      replyMessage: params.replyMessage,
    );
  }
}

class UpdateReplyParams extends Equatable {
  final int chatGroupId;
  final String documentId;
  final ChatReplyMessage replyMessage;

  const UpdateReplyParams({
    required this.chatGroupId,
    required this.documentId,
    required this.replyMessage,
  });

  @override
  List<Object?> get props => [chatGroupId, documentId];
}
