import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/account/onboarding_details.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class GetOnboardingDetailsUseCase
    implements UseCase<DataState<OnboardingDetailsResponseModel>, NoParams> {
  final AccountRepository _accountRepository;

  GetOnboardingDetailsUseCase(this._accountRepository);

  @override
  Future<DataState<OnboardingDetailsResponseModel>> call(NoParams params) {
    return _accountRepository.getOnboardingDetails();
  }
}
