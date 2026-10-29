import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/get_pending_audios_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetPendingAudiosUseCase
    implements UseCase<DataState<GetPendingAudiosResponseModel>, NoParams> {
  final ChatRepository _chatRepository;

  GetPendingAudiosUseCase(this._chatRepository);

  @override
  Future<DataState<GetPendingAudiosResponseModel>> call(NoParams params) async {
    return _chatRepository.getPendingAudios();
  }
}
