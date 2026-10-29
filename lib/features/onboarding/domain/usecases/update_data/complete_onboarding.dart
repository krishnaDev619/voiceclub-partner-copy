import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/update_data_repository.dart';

class CompleteOnboardingUseCase
    implements UseCase<DataState<void>, CompleteOnboardingParams> {
  final UpdateDataRepository _updateDataRepository;

  CompleteOnboardingUseCase(this._updateDataRepository);

  @override
  Future<DataState<void>> call(CompleteOnboardingParams params) {
    return _updateDataRepository.completeOnboarding(
      phone: params.phone,
      bypassKyc: params.bypassKyc,
    );
  }
}

class CompleteOnboardingParams extends Equatable {
  final String phone;
  final bool bypassKyc;

  const CompleteOnboardingParams({
    required this.phone,
    required this.bypassKyc,
  });

  @override
  List<Object> get props => [phone];
}
