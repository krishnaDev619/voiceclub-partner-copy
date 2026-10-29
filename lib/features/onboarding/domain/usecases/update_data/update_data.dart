import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/update_data/onboarding_data_model.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/update_data_repository.dart';

class UpdateDataUseCase implements UseCase<DataState, Params> {
  final UpdateDataRepository _updateDataRepository;

  UpdateDataUseCase(this._updateDataRepository);

  @override
  Future<DataState> call(Params params) {
    return _updateDataRepository.updateData(params.updateDataModel);
  }
}

class Params extends Equatable {
  final OnboardingDataModel updateDataModel;

  const Params({required this.updateDataModel});

  @override
  List<Object> get props => [updateDataModel];
}
