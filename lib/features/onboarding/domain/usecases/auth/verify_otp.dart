import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/auth/verify_otp_response.dart';
import 'package:voiceclub_partner/features/onboarding/domain/repository/auth_repository.dart';

class VerifyOTPUseCase
    implements UseCase<DataState<VerifyOtpResponseModel>, VerifyOtpParams> {
  final AuthRepository _authRepository;

  VerifyOTPUseCase(this._authRepository);

  @override
  Future<DataState<VerifyOtpResponseModel>> call(VerifyOtpParams params) {
    return _authRepository.verifyOTP(
      phoneNumber: params.phoneNo,
      otp: params.otp,
    );
  }
}

class VerifyOtpParams extends Equatable {
  final String phoneNo;
  final String otp;

  const VerifyOtpParams({required this.phoneNo, required this.otp});

  @override
  List<Object> get props => [phoneNo, otp];
}
