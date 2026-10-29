import 'dart:io';

import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/kyc_file/upload_kyc_file_response.dart';

abstract class KYCFileRepository {
  Future<DataState<UploadKYCFileResponseModel>> uploadKYCFile({
    required File file,
    required String extension,
  });
}
