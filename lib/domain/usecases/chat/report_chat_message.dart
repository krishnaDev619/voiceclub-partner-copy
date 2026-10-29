import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class ReportChatMessageUsecase implements UseCase<void, Params> {
  final ChatRepository _chatRepository;

  ReportChatMessageUsecase(this._chatRepository);

  @override
  Future<void> call(Params params) async {
    return _chatRepository.reportChatMessage(
      chatGroupId: params.chatGroupId,
      documentId: params.documentId,
      reason: params.reason,
    );
  }
}

class Params extends Equatable {
  final int chatGroupId;
  final String documentId;
  final String? reason;

  const Params({
    required this.chatGroupId,
    required this.documentId,
    this.reason,
  });

  @override
  List<Object?> get props => [chatGroupId, documentId, reason];
}
