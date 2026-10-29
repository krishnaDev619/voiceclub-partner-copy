import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class MarkOnboardingStageCourseCompletedUseCase
    implements UseCase<DataState, NoParams> {
  final AccountRepository _supplyAccountRepository;

  MarkOnboardingStageCourseCompletedUseCase(this._supplyAccountRepository);

  @override
  Future<DataState> call(NoParams params) {
    return _supplyAccountRepository.markOnboardingStageCourseCompleted();
  }
}
