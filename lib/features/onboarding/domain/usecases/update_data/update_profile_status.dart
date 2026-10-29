import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/update_data_repository.dart';

class UpdateProfileStatusUseCase
    implements UseCase<DataState, UpdateProfileStatusParams> {
  final UpdateDataRepository _updateDataRepository;

  UpdateProfileStatusUseCase(this._updateDataRepository);

  @override
  Future<DataState> call(UpdateProfileStatusParams params) {
    return _updateDataRepository.updateProfileStatus(
      phone: params.phone,
      profileStatus: params.profileStatus,
    );
  }
}

class UpdateProfileStatusParams extends Equatable {
  final String phone;
  final String profileStatus;

  const UpdateProfileStatusParams({
    required this.phone,
    required this.profileStatus,
  });

  @override
  List<Object> get props => [phone, profileStatus];
}
