import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/auth_repository.dart';

class LogoutUsecase implements UseCase<DataState<void>, NoParams> {
  final AuthRepository _authRepository;
  LogoutUsecase(this._authRepository);

  @override
  Future<DataState<void>> call(NoParams params) {
    return _authRepository.logout();
  }
}
