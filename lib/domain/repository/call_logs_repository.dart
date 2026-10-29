import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/call_logs/fetch_call_logs_for_pair_response.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';

abstract class CallLogsRepository {
  Future<DataState<FetchCallLogsForPairResponseModel>> fetchCallLogsForPair({
    required int userId,
    required int page,
    required int pageSize,
  });

  Future<DataState<FileResponseModel>> fetchLogRecordingUrl({
    required String filename,
  });
}
