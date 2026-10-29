import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class MarkOnboardingCompletedUseCase
    implements UseCase<DataState<void>, NoParams> {
  final AccountRepository _accountRepository;

  MarkOnboardingCompletedUseCase(this._accountRepository);

  @override
  Future<DataState<void>> call(NoParams params) {
    return _accountRepository.markOnboardingCompleted();
  }
}
