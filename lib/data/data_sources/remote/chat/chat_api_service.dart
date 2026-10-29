import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/chat/active_users_response.dart';
import 'package:voiceclub_partner/data/models/chat/chat_features_unlock_criteria_response.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/data/models/chat/fetch_unseen_count_response.dart';
import 'package:voiceclub_partner/data/models/chat/get_chat_filter_options_response.dart';
import 'package:voiceclub_partner/data/models/chat/get_chat_groups_response.dart';
import 'package:voiceclub_partner/data/models/chat/get_notes_response.dart';
import 'package:voiceclub_partner/data/models/chat/get_pending_audios_response.dart';
import 'package:voiceclub_partner/data/models/chat/send_chat_message_response.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';

part 'chat_api_service.g.dart';

@RestApi()
abstract class ChatApiService {
  factory ChatApiService(Dio dio) = _ChatApiService;

  @GET(APIConstants.getChatGroupsRoute)
  Future<HttpResponse<GetChatGroupsResponseModel>> getChatGroups({
    @Path('category') required String category,
    @Query('query') String? searchQuery,
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @POST(APIConstants.sendChatMessageRoute)
  Future<HttpResponse<SendChatMessageResponseModel>> sendChatMessage({
    @Field('group_id') required int groupId,
    @Field('type') required String type,
    @Field('attachment_url') required String attachmentUrl,
    @Field('content') required String content,
    @Field('is_session_ongoing') required bool isSessionOngoing,
  });

  @POST(APIConstants.uploadChatAttachmentRoute)
  @Headers({'Content-Type': 'multipart/form-data'})
  @MultiPart()
  Future<HttpResponse<FileResponseModel>> uploadChatAttachment({
    @Part(name: 'attachment') required File attachment,
    @Path('extension') required String extension,
  });

  @GET(APIConstants.fetchChatFeaturesUnlockCriteriaRoute)
  Future<HttpResponse<ChatFeaturesUnlockCriteriaResponseModel>>
  fetchChatFeaturesUnlockCriteria();

  @GET(APIConstants.fetchUnseenCountRoute)
  Future<HttpResponse<FetchUnseenCountResponseModel>> fetchUnseenCount({
    @Query('category') required String category,
  });

  @GET(APIConstants.getChatGroupByAccountIdRoute)
  Future<HttpResponse<ChatGroup>> getChatGroupByAccountId({
    @Path('accountId') required int accountId,
  });

  @POST(APIConstants.sendBroadcastMessageRoute)
  Future<HttpResponse> sendBroadcastMessage({
    @Field('group_ids') required List<int> groupIds,
    @Field('type') required String type,
    @Field('message') required String message,
    @Field('attachment_url') required String attachmentUrl,
    @Field('message_type') required String messageType,
  });

  @POST(APIConstants.sendAudioGreetingRoute)
  Future<HttpResponse> sendAudioGreeting({
    @Field('account_id') required int accountId,
  });

  @GET(APIConstants.getSupplyChatFilterOptionsRoute)
  Future<HttpResponse<GetChatFilterOptionsResponseModel>>
  getSupplyChatFilterOptions({@Path('category') required String category});

  @POST(APIConstants.getFilteredChatGroupsRoute)
  Future<HttpResponse<GetChatGroupsResponseModel>> getFilteredChatGroups({
    @Field('code') required String code,
    @Field('is_count') required bool isCount,
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @GET(APIConstants.getChatGroupByIdRoute)
  Future<HttpResponse<ChatGroup>> getChatGroupById({
    @Path('groupId') required int groupId,
  });

  @GET(APIConstants.getPendingAudiosRoute)
  Future<HttpResponse<GetPendingAudiosResponseModel>> getPendingAudios();

  @POST(APIConstants.updateCustomNameRoute)
  Future<HttpResponse> updateCustomName({
    @Field('name') required String name,
    @Field('account_id') required int accountId,
  });

  @GET(APIConstants.getActiveUsersRoute)
  Future<HttpResponse<ActiveUsersResponseModel>> getActiveUsers();

  @GET(APIConstants.getCallRecordingRoute)
  Future<HttpResponse<FileResponseModel>> getCallRecording({
    @Path('callId') required int callId,
  });

  @GET(APIConstants.getChatNoteRoute)
  Future<HttpResponse<GetNotesResponseModel>> getChatNote({
    @Path('accountId') required int accountId,
  });

  @POST(APIConstants.addChatNoteRoute)
  Future<HttpResponse> addChatNote({
    @Path('accountId') required int accountId,
    @Field('age') required int age,
    @Field('profession') required String profession,
    @Field('relationship') required String relationship,
    @Field('note_request') required Map<String, dynamic> noteRequest,
  });
}
