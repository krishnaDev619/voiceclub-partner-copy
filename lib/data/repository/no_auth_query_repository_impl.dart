import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/query/no_auth_query_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/query/query_firebase_service.dart';
import 'package:voiceclub_partner/data/models/query/query_message_model.dart';
import 'package:voiceclub_partner/data/models/query/start_session_response_model.dart';
import 'package:voiceclub_partner/domain/repository/no_auth_query_repository.dart';

class NoAuthQueryRepositoryImpl implements NoAuthQueryRepository {
  final NoAuthQueryApiService _apiService;
  final QueryFirebaseService _firebaseService;

  NoAuthQueryRepositoryImpl(this._apiService, this._firebaseService);

  @override
  Future<DataState<StartSessionResponseModel>> startSession({
    required String source,
    required int accountId,
  }) async {
    try {
      final response = await _apiService.startSession(
        source: source,
        accountId: accountId,
      );
      return toDataState(response);
    } on DioException catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<void>> sendMessage({
    required String sessionId,
    required String content,
    required int accountId,
  }) async {
    try {
      final response = await _apiService.sendMessage(
        sessionId: sessionId,
        messageType: QueryMessageType.TEXT.toQueryMessageTypeString(),
        content: content,
        accountId: accountId,
      );
      return toDataState(response);
    } on DioException catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<void>> endSession({
    required String sessionId,
    required int accountId,
  }) async {
    try {
      final response = await _apiService.endSession(
        sessionId: sessionId,
        accountId: accountId,
      );
      return toDataState(response);
    } on DioException catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Stream<List<QueryMessageModel>> watchMessages({required String sessionId}) {
    return _firebaseService
        .fetchQueryChatMessagesStream(sessionId: sessionId)
        .map(
          (documents) =>
              documents
                  .map(
                    (document) =>
                        QueryMessageModel.fromFirestore(document.data()),
                  )
                  .toList(),
        );
  }
}
