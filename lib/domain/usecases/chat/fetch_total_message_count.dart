import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class FetchTotalMessageCountUsecase
    implements UseCase<int, FetchTotalMessageCountParams> {
  final ChatRepository _chatRepository;

  FetchTotalMessageCountUsecase(this._chatRepository);

  @override
  Future<int> call(FetchTotalMessageCountParams params) async {
    return _chatRepository.fetchTotalMessageCount(
      chatGroupId: params.chatGroupId,
    );
  }
}

class FetchTotalMessageCountParams extends Equatable {
  final int chatGroupId;

  const FetchTotalMessageCountParams({required this.chatGroupId});

  @override
  List<Object> get props => [chatGroupId];
}
