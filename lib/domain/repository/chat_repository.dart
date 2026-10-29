import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
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

abstract class ChatRepository {
  // API methods
  Future<DataState<GetChatGroupsResponseModel>> getChatGroups({
    required String category,
    String? searchQuery,
    required int page,
    required int pageSize,
  });

  Future<DataState<SendChatMessageResponseModel>> sendChatMessage({
    required int groupId,
    required String type,
    required String attachmentUrl,
    required String content,
    required bool isSessionOngoing,
  });

  Future<DataState<FileResponseModel>> uploadChatAttachment({
    required File attachment,
    required String extension,
  });

  Future<DataState<ChatFeaturesUnlockCriteriaResponseModel>>
  fetchChatFeaturesUnlockCriteria();

  Future<DataState<FetchUnseenCountResponseModel>> fetchUnseenCount({
    required String category,
  });

  Future<DataState<ChatGroup>> getChatGroupByAccountId({
    required int accountId,
  });

  Future<DataState<String?>> sendBroadcastMessage({
    required List<int> groupIds,
    required String type,
    required String message,
    required String attachmentUrl,
    required String messageType,
  });

  Future<DataState<void>> sendAudioGreeting({required int accountId});

  Future<DataState<GetChatFilterOptionsResponseModel>>
  getSupplyChatFilterOptions({required String category});

  Future<DataState<GetChatGroupsResponseModel>> getFilteredChatGroups({
    required String code,
    required int page,
    required int pageSize,
    required bool isCount,
  });

  Future<DataState<ChatGroup>> getChatGroupById({required int groupId});

  Future<DataState<GetPendingAudiosResponseModel>> getPendingAudios();

  Future<DataState<void>> updateCustomName({
    required String name,
    required int accountId,
  });

  Future<DataState<ActiveUsersResponseModel>> getActiveUsers();

  Future<DataState<FileResponseModel>> getCallRecording({required int callId});

  Future<DataState<GetNotesResponseModel>> getChatNotes({
    required int accountId,
  });

  Future<DataState> addChatNote({
    required int accountId,
    required int age,
    required String profession,
    required String relationship,
    required Map<String, dynamic> noteRequest,
  });

  // Database Methods
  List<ChatGroup> getChatGroupsFromDatabase({required ChatTabFilter filter});

  void saveChatGroupsToDatabase({
    required List<ChatGroup> chatGroups,
    required ChatTabFilter filter,
  });

  void deleteChatGroupsFromDatabase({required ChatTabFilter filter});

  int? getLocalMessageCount({required int chatGroupId});

  void saveLocalMessageCount({required int chatGroupId, required int count});

  int? getLocalFetchedMessageCount({required int chatGroupId});

  void saveLocalFetchedMessageCount({
    required int chatGroupId,
    required int count,
  });

  double getScrollPostion({required int chatGroupId});

  void saveScrollPosition({
    required int chatGroupId,
    required double scrollPosition,
  });

  // Firebase methods
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchInitMessagesStream({required int chatGroupId, required int? limit});

  Future<QuerySnapshot<Map<String, dynamic>>> fetchChatMessages({
    required int chatGroupId,
    required QueryDocumentSnapshot lastDocument,
  });

  Future<int> fetchTotalMessageCount({required int chatGroupId});

  Future<void> reportChatMessage({
    required int chatGroupId,
    required String documentId,
    String? reason,
  });

  Future<void> deleteChatMessage({
    required int chatGroupId,
    required String documentId,
  });

  Future<void> updateReaction({
    required int chatGroupId,
    required String documentId,
    required String reaction,
  });

  Future<void> updateReply({
    required int chatGroupId,
    required String documentId,
    required ChatReplyMessage replyMessage,
  });

  Stream<String?> fetchLastSeenMessageIdStream({required int chatGroupId});
}
