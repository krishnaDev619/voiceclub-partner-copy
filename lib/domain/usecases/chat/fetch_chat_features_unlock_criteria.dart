import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/chat/chat_features_unlock_criteria_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class FetchChatFeaturesUnlockCriteriaUsecase
    implements
        UseCase<DataState<ChatFeaturesUnlockCriteriaResponseModel>, NoParams> {
  final ChatRepository _chatRepository;

  FetchChatFeaturesUnlockCriteriaUsecase(this._chatRepository);

  @override
  Future<DataState<ChatFeaturesUnlockCriteriaResponseModel>> call(
    NoParams params,
  ) {
    return _chatRepository.fetchChatFeaturesUnlockCriteria();
  }
}
