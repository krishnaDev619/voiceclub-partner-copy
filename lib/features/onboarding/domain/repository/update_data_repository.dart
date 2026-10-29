import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/update_data/get_file_url_response.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/update_data/onboarding_data_model.dart';

abstract class UpdateDataRepository {
  Future<DataState> updateData(OnboardingDataModel updateDataModel);

  Future<DataState> updateProfileStatus({
    required String phone,
    required String profileStatus,
  });

  Future<DataState> updateSignDocument({
    required String documentPath,
    required String phoneNumber,
  });

  Future<DataState<GetFileUrlResponseModel>> getFileUrl({
    required String fileName,
  });

  Future<DataState> completeOnboarding({
    required String phone,
    required bool bypassKyc,
  });
}
