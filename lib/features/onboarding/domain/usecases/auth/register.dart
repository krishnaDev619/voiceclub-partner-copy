import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/auth_repository.dart';

class RegisterUsecase implements UseCase<DataState, RegisterParams> {
  final AuthRepository _authRepository;

  RegisterUsecase(this._authRepository);

  @override
  Future<DataState> call(RegisterParams params) {
    return _authRepository.register(
      phoneNumber: params.phoneNumber,
      gaid: params.gaid,
    );
  }
}

class RegisterParams extends Equatable {
  final String phoneNumber;
  final String? gaid;

  const RegisterParams({required this.phoneNumber, this.gaid});

  @override
  List<Object> get props => [phoneNumber];
}
