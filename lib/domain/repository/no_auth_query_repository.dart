import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/query/query_message_model.dart';
import 'package:voiceclub_partner/data/models/query/start_session_response_model.dart';

abstract class NoAuthQueryRepository {
  Future<DataState<StartSessionResponseModel>> startSession({
    required String source,
    required int accountId,
  });

  Future<DataState<void>> sendMessage({
    required String sessionId,
    required String content,
    required int accountId,
  });

  Future<DataState<void>> endSession({
    required String sessionId,
    required int accountId,
  });

  Stream<List<QueryMessageModel>> watchMessages({required String sessionId});
}
