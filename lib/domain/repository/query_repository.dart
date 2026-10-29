import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/query/get_daily_query_raised_count_response.dart';
import 'package:voiceclub_partner/data/models/query/get_query_session_response.dart';
import 'package:voiceclub_partner/data/models/query/get_unseen_kam_query_chat_message_count_response.dart';
import 'package:voiceclub_partner/data/models/query/list_query_sessions_response.dart';
import 'package:voiceclub_partner/data/models/query/start_session_response_model.dart';

abstract class QueryRepository {
  Future<DataState<StartSessionResponseModel>> startQuerySession({
    required String source,
  });

  Future<DataState<ListQuerySessionsResponse>> listQuerySessions({
    required int page,
    required int pageSize,
  });

  Future<DataState<GetQuerySessionResponse>> getQuerySession({
    required String sessionId,
  });

  Future<DataState<void>> sendQueryBotMessage({
    required String sessionId,
    String? content,
    File? attachment,
    required String messageType,
    String? actionOptionType,
    String? actionValue,
    int? externalId,
  });

  Future<DataState<void>> endQuerySession({required String sessionId});

  Future<DataState<GetUnseenKamQueryChatMessageCountResponse>>
  getUnseenKamQueryChatMessageCount();

  // Firebase method
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchQueryChatMessagesStream({required String sessionId});

  Future<DataState<GetDailyQueryRaisedCountResponse>>
  getDailyQueryRaisedCount();

  Future<DataState<void>> updateAiCallCount({required String sessionId});
}
