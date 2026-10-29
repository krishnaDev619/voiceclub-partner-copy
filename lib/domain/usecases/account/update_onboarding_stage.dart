import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/account_repository.dart';

class UpdateOnboardingStageUseCase
    implements UseCase<DataState, OnboardingStageUpdateParams> {
  final AccountRepository _supplyAccountRepository;

  UpdateOnboardingStageUseCase(this._supplyAccountRepository);

  @override
  Future<DataState> call(OnboardingStageUpdateParams params) {
    return _supplyAccountRepository.updateOnboardingStage(
      stage: params.stage.name,
      date: DateTime.now().toIso8601String(),
    );
  }
}

class OnboardingStageUpdateParams extends Equatable {
  final TutorialStage stage;

  const OnboardingStageUpdateParams({required this.stage});

  @override
  List<Object> get props => [stage];
}
