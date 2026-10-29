import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/auth/profile_response.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/auth_repository.dart';

class GetProfileUseCase
    implements UseCase<DataState<ProfileResponseModel>, NoParams> {
  final AuthRepository _authRepository;

  GetProfileUseCase(this._authRepository);

  @override
  Future<DataState<ProfileResponseModel>> call(NoParams params) {
    return _authRepository.getProfile();
  }
}
