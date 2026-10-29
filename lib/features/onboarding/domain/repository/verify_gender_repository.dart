import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/verify_gender/verify_gender_response_model.dart';

abstract class VerifyGenderRepository {
  Future<DataState<VerifyGenderResponseModel>> verifyGender({
    required Map<String, dynamic> s3Object,
  });
}
