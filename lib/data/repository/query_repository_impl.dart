import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/query/query_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/query/query_firebase_service.dart';
import 'package:voiceclub_partner/data/models/query/get_daily_query_raised_count_response.dart';
import 'package:voiceclub_partner/data/models/query/get_query_session_response.dart';
import 'package:voiceclub_partner/data/models/query/get_unseen_kam_query_chat_message_count_response.dart';
import 'package:voiceclub_partner/data/models/query/list_query_sessions_response.dart';
import 'package:voiceclub_partner/data/models/query/start_session_response_model.dart';
import 'package:voiceclub_partner/domain/repository/query_repository.dart';

class QueryRepositoryImpl implements QueryRepository {
  final QueryFirebaseService _queryFirebaseService;
  final QueryApiService _queryApiService;

  QueryRepositoryImpl(this._queryFirebaseService, this._queryApiService);

  @override
  Future<DataState<StartSessionResponseModel>> startQuerySession({
    required String source,
  }) async {
    try {
      final response = await _queryApiService.startQueryBotSession(
        source: source,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ListQuerySessionsResponse>> listQuerySessions({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _queryApiService.listQuerySessions(
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetQuerySessionResponse>> getQuerySession({
    required String sessionId,
  }) async {
    try {
      final response = await _queryApiService.getQuerySession(
        sessionId: sessionId,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> sendQueryBotMessage({
    required String sessionId,
    required String messageType,
    String? content,
    File? attachment,
    String? actionOptionType,
    String? actionValue,
    int? externalId,
  }) async {
    try {
      final response = await _queryApiService.sendQueryBotMessage(
        sessionId: sessionId,
        messageType: messageType,
        content: content,
        attachment: attachment,
        actionOptionType: actionOptionType,
        actionValue: actionValue,
        externalId: externalId?.toString(),
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  // Firebase methods
  @override
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchQueryChatMessagesStream({required String sessionId}) {
    return _queryFirebaseService.fetchQueryChatMessagesStream(
      sessionId: sessionId,
    );
  }

  @override
  Future<DataState<void>> endQuerySession({required String sessionId}) async {
    try {
      final response = await _queryApiService.endQueryBotSession(
        sessionId: sessionId,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetUnseenKamQueryChatMessageCountResponse>>
  getUnseenKamQueryChatMessageCount() async {
    try {
      final response =
          await _queryApiService.getUnseenKamQueryChatMessageCount();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetDailyQueryRaisedCountResponse>>
  getDailyQueryRaisedCount() async {
    try {
      final response = await _queryApiService.getDailyQueryRaisedCount();
      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> updateAiCallCount({required String sessionId}) async {
    try {
      final response = await _queryApiService.updateAiCallCount(
        sessionId: sessionId,
      );
      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
