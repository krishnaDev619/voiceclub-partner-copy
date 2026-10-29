import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/auth/profile_response.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/auth/verify_otp_response.dart';

abstract class AuthRepository {
  Future<DataState> register({required String phoneNumber, String? gaid});

  Future<DataState<VerifyOtpResponseModel>> verifyOTP({
    required String phoneNumber,
    required String otp,
  });

  Future<DataState<ProfileResponseModel>> getProfile();
}
