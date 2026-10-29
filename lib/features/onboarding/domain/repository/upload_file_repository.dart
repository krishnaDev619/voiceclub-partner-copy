import 'dart:io';

import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/verify_gender/upload_file_response_model.dart';

abstract class UploadFileRepository {
  Future<DataState<UploadFileResponseModel>> uploadOnboardingFile({
    required String extension,
    required File file,
  });
}
