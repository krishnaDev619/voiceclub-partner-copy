import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/kyc_file/get_file_url.dart';

abstract class AgreementRepository {
  // API methods
  Future<DataState> updateSignDocument({
    required String documentPath,
    required String phoneNumber,
  });

  Future<DataState<GetFileUrlResponseModel>> getFileUrl({
    required String fileName,
  });
}
