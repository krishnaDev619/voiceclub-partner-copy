import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetLocalMessageCountUsecase
    implements UseCase<int?, GetLocalMessageCountParams> {
  final ChatRepository _chatRepository;

  GetLocalMessageCountUsecase(this._chatRepository);

  @override
  Future<int?> call(GetLocalMessageCountParams params) async {
    return _chatRepository.getLocalMessageCount(
      chatGroupId: params.chatGroupId,
    );
  }
}

class GetLocalMessageCountParams extends Equatable {
  final int chatGroupId;

  const GetLocalMessageCountParams({required this.chatGroupId});

  @override
  List<Object> get props => [chatGroupId];
}
