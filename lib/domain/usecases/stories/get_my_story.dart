import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/stories/get_my_story_response.dart';
import 'package:voiceclub_partner/domain/repository/stories_repository.dart';

class GetMyStoryUsecase
    implements UseCase<DataState<GetMyStoryResponseModel>, NoParams> {
  final StoriesRepository _storiesRepository;
  GetMyStoryUsecase(this._storiesRepository);

  @override
  Future<DataState<GetMyStoryResponseModel>> call(NoParams params) {
    return _storiesRepository.getMyStory();
  }
}
