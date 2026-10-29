import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/probation_repository.dart';

class MarkProbationCourseCompletedUsecase
    implements UseCase<DataState<void>, NoParams> {
  final MetricsRepository _probationRepository;

  MarkProbationCourseCompletedUsecase(this._probationRepository);

  @override
  Future<DataState<void>> call(NoParams params) {
    return _probationRepository.markProbationCourseCompleted();
  }
}
