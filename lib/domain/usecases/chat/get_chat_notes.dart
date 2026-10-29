import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/get_notes_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetChatNoteUseCase
    implements UseCase<DataState<GetNotesResponseModel>, Params> {
  final ChatRepository _chatRepository;

  GetChatNoteUseCase(this._chatRepository);

  @override
  Future<DataState<GetNotesResponseModel>> call(Params params) async {
    return _chatRepository.getChatNotes(accountId: params.accountId);
  }
}

class Params extends Equatable {
  final int accountId;

  const Params({required this.accountId});

  @override
  List<Object> get props => [accountId];
}
