import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/stories_repository.dart';

class DeleteStoryUsecase implements UseCase<DataState<void>, Params> {
  final StoriesRepository _storiesRepository;
  DeleteStoryUsecase(this._storiesRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _storiesRepository.deleteStory(params.storyId);
  }
}

class Params extends Equatable {
  final int storyId;

  const Params({required this.storyId});

  @override
  List<Object> get props => [storyId];
}
