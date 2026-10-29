import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class SaveScrollPositionUsecase implements UseCase<void, Params> {
  final ChatRepository _chatRepository;

  SaveScrollPositionUsecase(this._chatRepository);

  @override
  Future<void> call(Params params) async {
    return _chatRepository.saveScrollPosition(
      chatGroupId: params.chatGroupId,
      scrollPosition: params.scrollPosition,
    );
  }
}

class Params extends Equatable {
  final int chatGroupId;
  final double scrollPosition;

  const Params({required this.chatGroupId, required this.scrollPosition});

  @override
  List<Object> get props => [chatGroupId, scrollPosition];
}
