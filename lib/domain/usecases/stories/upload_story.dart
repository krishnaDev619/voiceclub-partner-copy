import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/stories_repository.dart';

class UploadStoryUsecase implements UseCase<DataState<void>, Params> {
  final StoriesRepository _storiesRepository;
  UploadStoryUsecase(this._storiesRepository);

  @override
  Future<DataState<void>> call(Params params) {
    return _storiesRepository.uploadStory(
      params.color,
      params.mediaUrl,
      params.mediaType,
    );
  }
}

class Params extends Equatable {
  final String color, mediaUrl, mediaType;
  const Params({
    required this.color,
    required this.mediaUrl,
    required this.mediaType,
  });

  @override
  List<Object> get props => [color, mediaUrl, mediaType];
}
