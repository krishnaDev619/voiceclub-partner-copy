import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/active_users_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class GetActiveUsersUseCase
    implements UseCase<DataState<ActiveUsersResponseModel>, NoParams> {
  final ChatRepository _chatRepository;

  GetActiveUsersUseCase(this._chatRepository);

  @override
  Future<DataState<ActiveUsersResponseModel>> call(NoParams params) {
    return _chatRepository.getActiveUsers();
  }
}
