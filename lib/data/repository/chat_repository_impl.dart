import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/local/chat/chat_database_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/chat/chat_api_service.dart';
import 'package:voiceclub_partner/data/data_sources/remote/chat/chat_firebase_service.dart';
import 'package:voiceclub_partner/data/models/chat/active_users_response.dart';
import 'package:voiceclub_partner/data/models/chat/chat_features_unlock_criteria_response.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/data/models/chat/chat_reply_message.dart';
import 'package:voiceclub_partner/data/models/chat/fetch_unseen_count_response.dart';
import 'package:voiceclub_partner/data/models/chat/get_chat_filter_options_response.dart';
import 'package:voiceclub_partner/data/models/chat/get_chat_groups_response.dart';
import 'package:voiceclub_partner/data/models/chat/get_notes_response.dart';
import 'package:voiceclub_partner/data/models/chat/get_pending_audios_response.dart';
import 'package:voiceclub_partner/data/models/chat/send_chat_message_response.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatApiService _chatApiService;
  final ChatDatabaseService _chatDatabaseService;
  final ChatFirebaseService _chatFirebaseService;

  ChatRepositoryImpl(
    this._chatApiService,
    this._chatFirebaseService,
    this._chatDatabaseService,
  );

  @override
  Future<DataState<GetChatGroupsResponseModel>> getChatGroups({
    required String category,
    String? searchQuery,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _chatApiService.getChatGroups(
        category: category,
        searchQuery: searchQuery,
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<SendChatMessageResponseModel>> sendChatMessage({
    required int groupId,
    required String type,
    required String attachmentUrl,
    required String content,
    required bool isSessionOngoing,
  }) async {
    try {
      final response = await _chatApiService.sendChatMessage(
        groupId: groupId,
        type: type,
        attachmentUrl: attachmentUrl,
        content: content,
        isSessionOngoing: isSessionOngoing,
      );

      if (response.response.statusCode == 200) {
        final data = SendChatMessageResponseModel(
          code: response.data.code,
          count: response.data.count,
          message: response.data.message,
          attachmentUrl: attachmentUrl,
          id: response.data.id,
          limit: response.data.limit,
        );
        return DataSuccess(data);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<FileResponseModel>> uploadChatAttachment({
    required File attachment,
    required String extension,
  }) async {
    try {
      final response = await _chatApiService.uploadChatAttachment(
        attachment: attachment,
        extension: extension,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ChatFeaturesUnlockCriteriaResponseModel>>
  fetchChatFeaturesUnlockCriteria() async {
    try {
      final response = await _chatApiService.fetchChatFeaturesUnlockCriteria();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<FetchUnseenCountResponseModel>> fetchUnseenCount({
    required String category,
  }) async {
    try {
      final response = await _chatApiService.fetchUnseenCount(
        category: category,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ChatGroup>> getChatGroupByAccountId({
    required int accountId,
  }) async {
    try {
      final response = await _chatApiService.getChatGroupByAccountId(
        accountId: accountId,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<String?>> sendBroadcastMessage({
    required List<int> groupIds,
    required String type,
    required String message,
    required String attachmentUrl,
    required String messageType,
  }) async {
    try {
      final response = await _chatApiService.sendBroadcastMessage(
        groupIds: groupIds,
        type: type,
        message: message,
        attachmentUrl: attachmentUrl,
        messageType: messageType,
      );

      if (response.response.statusCode == 200) {
        return DataSuccess(attachmentUrl);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> sendAudioGreeting({required int accountId}) async {
    try {
      final response = await _chatApiService.sendAudioGreeting(
        accountId: accountId,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetChatFilterOptionsResponseModel>>
  getSupplyChatFilterOptions({required String category}) async {
    try {
      final response = await _chatApiService.getSupplyChatFilterOptions(
        category: category,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetChatGroupsResponseModel>> getFilteredChatGroups({
    required String code,
    required int page,
    required int pageSize,
    required bool isCount,
  }) async {
    try {
      final response = await _chatApiService.getFilteredChatGroups(
        code: code,
        page: page,
        pageSize: pageSize,
        isCount: isCount,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ChatGroup>> getChatGroupById({required int groupId}) async {
    try {
      final response = await _chatApiService.getChatGroupById(groupId: groupId);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetPendingAudiosResponseModel>> getPendingAudios() async {
    try {
      final response = await _chatApiService.getPendingAudios();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> updateCustomName({
    required int accountId,
    required String name,
  }) async {
    try {
      final response = await _chatApiService.updateCustomName(
        name: name,
        accountId: accountId,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ActiveUsersResponseModel>> getActiveUsers() async {
    try {
      final response = await _chatApiService.getActiveUsers();

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<FileResponseModel>> getCallRecording({
    required int callId,
  }) async {
    try {
      final response = await _chatApiService.getCallRecording(callId: callId);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetNotesResponseModel>> getChatNotes({
    required int accountId,
  }) async {
    try {
      final response = await _chatApiService.getChatNote(accountId: accountId);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState> addChatNote({
    required int accountId,
    required int age,
    required String profession,
    required String relationship,
    required Map<String, dynamic> noteRequest,
  }) async {
    try {
      final response = await _chatApiService.addChatNote(
        accountId: accountId,
        age: age,
        noteRequest: noteRequest,
        profession: profession,
        relationship: relationship,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  // Database Methods
  @override
  List<ChatGroup> getChatGroupsFromDatabase({required ChatTabFilter filter}) {
    return _chatDatabaseService.getChatGroupsFromDatabase(filter: filter);
  }

  @override
  void saveChatGroupsToDatabase({
    required List<ChatGroup> chatGroups,
    required ChatTabFilter filter,
  }) {
    return _chatDatabaseService.saveChatGroupsToDatabase(
      chatGroups: chatGroups,
      filter: filter,
    );
  }

  @override
  void deleteChatGroupsFromDatabase({required ChatTabFilter filter}) {
    return _chatDatabaseService.deleteChatGroupsFromDatabase(filter: filter);
  }

  @override
  int? getLocalMessageCount({required int chatGroupId}) {
    return _chatDatabaseService.getLocalMessageCount(chatGroupId: chatGroupId);
  }

  @override
  void saveLocalMessageCount({required int chatGroupId, required int count}) {
    return _chatDatabaseService.saveLocalMessageCount(
      chatGroupId: chatGroupId,
      count: count,
    );
  }

  @override
  int? getLocalFetchedMessageCount({required int chatGroupId}) {
    return _chatDatabaseService.getLocalFetchedMessageCount(
      chatGroupId: chatGroupId,
    );
  }

  @override
  void saveLocalFetchedMessageCount({
    required int chatGroupId,
    required int count,
  }) {
    return _chatDatabaseService.saveLocalFetchedMessageCount(
      chatGroupId: chatGroupId,
      count: count,
    );
  }

  @override
  double getScrollPostion({required int chatGroupId}) {
    return _chatDatabaseService.getScrollPosition(chatGroupId: chatGroupId);
  }

  @override
  void saveScrollPosition({
    required int chatGroupId,
    required double scrollPosition,
  }) {
    return _chatDatabaseService.saveScrollPosition(
      chatGroupId: chatGroupId,
      scrollPosition: scrollPosition,
    );
  }

  // Firebase methods
  @override
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchInitMessagesStream({required int chatGroupId, required int? limit}) {
    return _chatFirebaseService.fetchInitMessagesStream(
      chatGroupId: chatGroupId,
      limit: limit,
    );
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> fetchChatMessages({
    required int chatGroupId,
    required QueryDocumentSnapshot lastDocument,
  }) {
    return _chatFirebaseService.fetchChatMessages(
      chatGroupId: chatGroupId,
      lastDocument: lastDocument,
    );
  }

  @override
  Future<int> fetchTotalMessageCount({required int chatGroupId}) {
    return _chatFirebaseService.fetchTotalMessageCount(
      chatGroupId: chatGroupId,
    );
  }

  @override
  Future<void> reportChatMessage({
    required int chatGroupId,
    required String documentId,
    String? reason,
  }) {
    return _chatFirebaseService.reportChatMessage(
      chatGroupId: chatGroupId,
      documentId: documentId,
      reason: reason,
    );
  }

  @override
  Future<void> deleteChatMessage({
    required int chatGroupId,
    required String documentId,
  }) {
    return _chatFirebaseService.deleteChatMessage(
      chatGroupId: chatGroupId,
      documentId: documentId,
    );
  }

  @override
  Future<void> updateReaction({
    required int chatGroupId,
    required String documentId,
    required String reaction,
  }) {
    return _chatFirebaseService.updateReaction(
      chatGroupId: chatGroupId,
      documentId: documentId,
      reaction: reaction,
    );
  }

  @override
  Stream<String?> fetchLastSeenMessageIdStream({required int chatGroupId}) {
    return _chatFirebaseService.fetchLastSeenMessageIdStream(
      chatGroupId: chatGroupId,
    );
  }

  @override
  Future<void> updateReply({
    required int chatGroupId,
    required String documentId,
    required ChatReplyMessage replyMessage,
  }) {
    return _chatFirebaseService.updateReply(
      chatGroupId: chatGroupId,
      documentId: documentId,
      replyMessage: replyMessage,
    );
  }
}
