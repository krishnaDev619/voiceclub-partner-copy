import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetScrollPositionUsecase
    implements UseCase<double, GetScrollPositionParams> {
  final ChatRepository _chatRepository;

  GetScrollPositionUsecase(this._chatRepository);

  @override
  Future<double> call(GetScrollPositionParams params) async {
    return _chatRepository.getScrollPostion(chatGroupId: params.chatGroupId);
  }
}

class GetScrollPositionParams extends Equatable {
  final int chatGroupId;

  const GetScrollPositionParams({required this.chatGroupId});

  @override
  List<Object> get props => [chatGroupId];
}
