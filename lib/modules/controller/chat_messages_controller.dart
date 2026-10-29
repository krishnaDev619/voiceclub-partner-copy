import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/calling/get_reverse_calling_stats_reponse.dart';
import 'package:voiceclub_partner/data/models/chat/chat_reply_message.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/display_chat_message.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/domain/usecases/calling/get_reverse_calling_stats.dart';
import 'package:voiceclub_partner/domain/usecases/chat/delete_chat_message.dart';
import 'package:voiceclub_partner/domain/usecases/chat/fetch_chat_messages.dart';
import 'package:voiceclub_partner/domain/usecases/chat/fetch_init_messages_stream.dart';
import 'package:voiceclub_partner/domain/usecases/chat/fetch_last_seen_timestamp_stream.dart';
import 'package:voiceclub_partner/domain/usecases/chat/fetch_total_message_count.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_local_fetched_message_count.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_local_message_count.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_scroll_position.dart';
import 'package:voiceclub_partner/domain/usecases/chat/save_local_fetched_message_count.dart';
import 'package:voiceclub_partner/domain/usecases/chat/save_local_message_count.dart';
import 'package:voiceclub_partner/domain/usecases/chat/send_chat_message.dart';
import 'package:voiceclub_partner/domain/usecases/chat/update_reaction.dart';
import 'package:voiceclub_partner/domain/usecases/chat/update_reply.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/view/auth/widgets/cancel_alert.dart';
import 'package:voiceclub_partner/view/chat/chat_overview_screen.dart';
import 'package:voiceclub_partner/view/partner_profile/widgets/report_message_bottom_sheet.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ChatMessagesControllerFactory {
  ChatMessagesController create({
    required int chatGroupId,
    required ChatTabFilter filter,
    required ScrollController scrollController,
  }) {
    return ChatMessagesController(
      chatGroupId: chatGroupId,
      scrollController: scrollController,
      filter: filter,
    );
  }
}

class ChatMessagesController extends GetxController {
  final int chatGroupId;
  final ChatTabFilter filter;
  final ScrollController scrollController;
  StreamSubscription<List<DisplayChatMessage?>>? _newChatSubscription;

  ChatMessagesController({
    required this.chatGroupId,
    required this.scrollController,
    required this.filter,
  });

  final chats = <DisplayChatMessage>[].obs;
  final _totalMessages = 0.obs;
  final _fetchedMessages = 20.obs;
  QueryDocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  final isLoading = false.obs;
  final reverseCallingStatsResponse = GetReverseCallingStatsResponseModel().obs;
  final lastSeenMessageId = Rxn<String>();
  final replyMessage = Rxn<ChatReplyMessage>();

  //Chat Audio Message
  RxMap<String, PlayerController> playerControllersMap =
      <String, PlayerController>{}.obs;

  //The path of current player which is being played
  var currentPlayerPath = "".obs;

  final theme = defaultTheme;
  Worker? callListener;

  @override
  void onInit() {
    super.onInit();
    // Call the function to fetch the last seen timestamp from Firebase
    fetchLastSeenMessageIdFromFirebase();
    // Call the function to fetch and listen to chat messages
    _streamInitChats();
    registerCallListener();
  }

  void onReportSelected({
    required DisplayChatMessage message,
    required ChatMember peerData,
  }) {
    HapticFeedback.vibrate();
    Get.bottomSheet(
      ReportMessageBottomSheet(
        content: message.content ?? '',
        chatGroupId: chatGroupId,
        documentId: message.id ?? '',
        peerData: peerData,
      ),
    );
  }

  void onDeleteSelected({
    required DisplayChatMessage message,
    required ChatMember peerData,
  }) {
    deleteMessage(
      content: message.content ?? '',
      type: ChatType.ChatTypeText,
      documentId: message.id ?? '',
      peerData: peerData,
    );
  }

  void onReactionSelected({
    required String reaction,
    required ChatMember peerData,
    required DisplayChatMessage message,
  }) {
    updateReaction(
      reaction: reaction,
      type: message.type ?? ChatType.ChatTypeText,
      documentId: message.id ?? '',
      peerData: peerData,
    );
  }

  void onCopySelected({required String text}) {
    Clipboard.setData(ClipboardData(text: text.trim()));
    HapticFeedback.vibrate();
    sl<AnalyticsService>().trackEvent(
      'textCopiedPartner',
      eventProperties: {'content': text.trim()},
    );
  }

  void onReplySelected({required DisplayChatMessage message}) {
    updateReplyMessage(message);
  }

  void updateReplyMessage(DisplayChatMessage message) {
    try {
      final msg = ChatReplyMessage.fromDisplayChatMessage(message);
      replyMessage(msg);
    } catch (e) {
      Logger.logMessage("Error in updateReplyMessage: ${e.toString()}");
    }
  }

  void removeReplyMessage() {
    HapticFeedback.mediumImpact();
    replyMessage.value = null;
  }

  void registerCallListener() {
    callListener = ever(sl<CallController>().incomingCallPayload, (
      callPayload,
    ) {
      if (callPayload.isNotEmpty) {
        pauseAllPlayers();
      }
    });
  }

  Future<void> getReverseStats(int accountId) async {
    try {
      var response = await sl<GetReverseCallingStatsUsecase>().call(
        GetReverseCallingStatsParams(demandAccountId: accountId),
      );
      if (response.data != null && response.error == null) {
        reverseCallingStatsResponse.value =
            response.data ?? GetReverseCallingStatsResponseModel();
      } else {
        reverseCallingStatsResponse.value =
            GetReverseCallingStatsResponseModel();
      }
    } catch (_) {
      reverseCallingStatsResponse.value = GetReverseCallingStatsResponseModel();
    }
  }

  /// Call this method everytime when you want to play or pause the player
  void stopAndStartPlayer({
    required String playerKey,
    required String screenName,
    bool isCallRecording = false,
    int callId = 0,
  }) {
    final currentController = playerControllersMap[currentPlayerPath.value];

    if (playerKey == currentPlayerPath.value) {
      // Toggle play/pause on the current player
      if (currentController != null) {
        if (currentController.playerState.isPlaying) {
          currentController.pausePlayer();
        } else {
          currentController.startPlayer();
        }
        if (isCallRecording) {
          sl<AnalyticsService>().trackEvent(
            'partnerCallRecording',
            eventProperties: {
              'status':
                  currentController.playerState.isPlaying ? "Pause" : "Play",
              'screenName': screenName,
            },
          );
        }
      }
      return;
    }

    pauseAllPlayers();

    // Start the selected player
    final selectedController = playerControllersMap[playerKey];
    if (selectedController != null) {
      selectedController.startPlayer();
      currentPlayerPath.value = playerKey;
    } else {
      currentPlayerPath.value = "";
    }
  }

  // Pause all players if they are playing
  void pauseAllPlayers() {
    try {
      for (var controller in playerControllersMap.values) {
        if (controller.playerState.isPlaying) {
          controller.pausePlayer();
        }
      }
    } catch (_) {}
  }

  Future<void> _streamInitChats() async {
    // Use the use case to get the chat messages stream
    await _fetchTotalMessages();
    await _fetchTotalFetchedMessages();
    final offset = await sl<GetScrollPositionUsecase>().call(
      GetScrollPositionParams(chatGroupId: chatGroupId),
    );
    final chatStream = await sl<FetchInitMessagesStreamUsecase>().call(
      FetchInitMessagesStreamParams(
        chatGroupId: chatGroupId,
        limit: _fetchedMessages.value > 0 ? _fetchedMessages.value : null,
      ),
    );
    final stream = chatStream.map((documentSnapshots) {
      try {
        if (_totalMessages.value > 20) {
          _updateLastDocument(documentSnapshots);
        }
        final messages =
            documentSnapshots.map((document) {
              final data = document.data();
              final displayMessage = DisplayChatMessage.fromFirestore(
                data,
                document.id,
              );
              if (!(displayMessage.isDeletedByPartner ?? false)) {
                return displayMessage;
              }
            }).toList();
        return messages;
      } catch (e) {
        // Handle any errors that may occur during mapping
        return <DisplayChatMessage>[];
      }
    });

    // Listen to the stream and update the chats list
    _newChatSubscription = stream.listen(
      (chatMessages) {
        if (chats.isEmpty) {
          for (final message in chatMessages) {
            if (message != null) {
              if (!chats.contains(message)) {
                chats.add(message);
              }
            }
          }
          scrollController.jumpTo(offset);
        } else {
          chatMessages.sort(
            (a, b) =>
                a?.createdAt?.compareTo(b?.createdAt ?? DateTime.now()) ?? 0,
          );
          for (final message in chatMessages) {
            if (message != null) {
              if (!chats.contains(message)) {
                chats.insert(0, message);
              } else {
                final index = chats.indexOf(message);
                if (chats[index].content != message.content ||
                    chats[index].reaction != message.reaction ||
                    chats[index].replyMessage != message.replyMessage) {
                  chats[index] = message;
                  update();
                }
              }
            }
          }
        }
      },
      onError: (error) {
        // Handle errors here
      },
    );
  }

  Future<void> _fetchTotalFetchedMessages() async {
    int fetchedMessageCount = 20;
    try {
      fetchedMessageCount =
          await sl<GetLocalFetchedMessageCountUsecase>().call(
            GetLocalFetchedMessageCountParams(chatGroupId: chatGroupId),
          ) ??
          20;
    } catch (_) {
    } finally {
      _fetchedMessages(fetchedMessageCount);
    }
  }

  Future<void> _saveTotalFetchedMessages() async {
    await sl<SaveLocalFetchedMessageCountUsecase>().call(
      SaveLocalFetchedMessageCountParams(
        chatGroupId: chatGroupId,
        count: (chats.length / 20).round() * 20,
      ),
    );
  }

  Future<void> _fetchTotalMessages() async {
    int messageCount = 0;
    try {
      messageCount = await sl<FetchTotalMessageCountUsecase>().call(
        FetchTotalMessageCountParams(chatGroupId: chatGroupId),
      );
    } catch (_) {
      messageCount =
          await sl<GetLocalMessageCountUsecase>().call(
            GetLocalMessageCountParams(chatGroupId: chatGroupId),
          ) ??
          0;
    } finally {
      _totalMessages(messageCount);
      await sl<SaveLocalMessageCountUsecase>().call(
        SaveLocalMessageCountParams(
          chatGroupId: chatGroupId,
          count: _totalMessages.value,
        ),
      );
    }
  }

  Future<void> fetchMoreChats() async {
    if (_lastDocument != null) {
      isLoading(true);
      final moreChatsSnapshot = await sl<FetchChatMessagesUsecase>().call(
        FetchChatMessagesParams(
          chatGroupId: chatGroupId,
          lastDocument: _lastDocument!,
        ),
      );
      _updateLastDocument(moreChatsSnapshot.docs);
      final chatMessages =
          moreChatsSnapshot.docs.map((document) {
            final data = document.data();
            final displayMessage = DisplayChatMessage.fromFirestore(
              data,
              document.id,
            );
            if (!(displayMessage.isDeletedByPartner ?? false)) {
              return displayMessage;
            }
          }).toList();
      for (final message in chatMessages) {
        if (message != null) {
          if (!chats.contains(message)) {
            chats.add(message);
          }
        }
      }
      _saveTotalFetchedMessages();
      isLoading(false);
    }
  }

  void _updateLastDocument(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents,
  ) {
    if (documents.length >= 20) {
      _lastDocument = documents.last;
    } else {
      // No more documents to fetch
      _lastDocument = null;
    }
  }

  void _leaveChat() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final overviewController = Get.find<ChatOverviewController>();
    chatSearchController.clear();
    overviewController.fetchChats(page: 1);
  }

  Future<void> sendMessage({
    required CategoryCode code,
    required ChatType chatType,
    required Map<String, dynamic> eventProperties,
    required ChatTier tier,
    required ChatMember peer,
    required bool isSessionOngoing,
    File? attachment,
    String? attachmentUrl,
    String content = '',
    bool pretext = false,
  }) async {
    // Assign reply message to temp variable so that it can be removed in UI
    final reply = replyMessage.value;
    removeReplyMessage();
    final response = await sl<SendChatMessageUsecase>().call(
      SendChatMessageParams(
        groupId: chatGroupId,
        type: chatType.toChatTypeString(),
        attachment: attachment,
        attachmentUrl: attachmentUrl,
        isSessionOngoing: isSessionOngoing,
        content: content,
      ),
    );
    String message = 'Your message could not be sent';
    const prefix = 'Partner';
    if (response.error != null) {
      try {
        message =
            (response.error?.response?.data as Map<String, dynamic>)['message'];
      } catch (_) {}
      eventProperties['reason'] = message;
      sl<AnalyticsService>().trackEvent(
        'chatFail$prefix',
        eventProperties: eventProperties,
      );
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.liveMessageNotSent.tr,
        subtitle: message,
      );
      update();
    } else {
      if (response.data?.code == 'ERROR') {
        message = response.data?.message ?? 'Your message could not be sent';
        eventProperties['reason'] = message;
        sl<AnalyticsService>().trackEvent(
          'chatFail$prefix',
          eventProperties: eventProperties,
        );
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.liveMessageNotSent.tr,
          subtitle: message,
        );
      } else {
        checkAndUpdateReply(
          documentId: response.data?.id.toString() ?? "0",
          peerData: peer,
          message: reply,
        );
        if (reply?.content?.isNotEmpty ?? false) {
          eventProperties['reply'] = reply?.content;
        }
        final attachmentUrl = response.data?.attachmentUrl ?? '';
        if (attachmentUrl.isNotEmpty) {
          eventProperties['attachmentUrl'] = attachmentUrl;
        } else if (chatType == ChatType.ChatTypeText) {
          eventProperties['pretext'] = pretext;
          eventProperties['content'] = content;
        }
        sl<AnalyticsService>().trackEvent(
          'chatSuccess$prefix',
          eventProperties: eventProperties,
        );
      }
      update();
      Get.find<ChatOverviewController>().fetchChats(page: 1);
    }
  }

  void fetchLastSeenMessageIdFromFirebase() async {
    final lastSeenMessageIdStream =
        await sl<FetchLastSeenMessageIdStreamUseCase>().call(
          FetchLastSeenMessageIdStreamParams(chatGroupId: chatGroupId),
        );
    lastSeenMessageIdStream.listen((lastSeenId) {
      if (lastSeenId != null) {
        if (lastSeenId != lastSeenMessageId.value) {
          lastSeenMessageId.value = lastSeenId;
        }
      }
    });
  }

  void deleteMessage({
    required String content,
    required ChatType type,
    required String documentId,
    required ChatMember peerData,
  }) async {
    try {
      HapticFeedback.vibrate();
      final result = await Get.dialog<bool?>(
        CancelAlertDialog(
          title: LocaleKeys.liveDeleteMessageFrom.trParams({
            'name': peerData.user?.name ?? '',
          }),
          subtitle: LocaleKeys.liveAreYouSureYouWant.tr,
        ),
      );
      if (result ?? false) {
        HapticFeedback.vibrate();
        await sl<DeleteChatMessageUsecase>().call(
          DeleteChatMessageParams(
            chatGroupId: chatGroupId,
            documentId: documentId,
          ),
        );
        chats.removeWhere((chat) => chat.id == documentId);
        sl<AnalyticsService>().trackEvent(
          "deleteMessagePartner",
          eventProperties: {
            "content": content,
            "type": type.name,
            "groupId": chatGroupId,
            "demandName": peerData.user?.name,
            "demandNumber": peerData.user?.phoneNumber,
            "demandUid": peerData.user?.id,
          },
        );
      }
    } catch (_) {}
  }

  void updateReaction({
    required String reaction,
    required ChatType type,
    required String documentId,
    required ChatMember peerData,
  }) async {
    try {
      HapticFeedback.vibrate();
      await sl<UpdateReactionUseCase>().call(
        UpdateReactionParams(
          chatGroupId: chatGroupId,
          documentId: documentId,
          reaction: reaction,
        ),
      );
      sl<AnalyticsService>().trackEvent(
        "chatReactPartner",
        eventProperties: {
          "reaction": reaction,
          "type": type.name,
          "documentId": documentId,
          "groupId": chatGroupId,
          "demandName": peerData.user?.name,
          "demandNumber": peerData.user?.phoneNumber,
          "demandUid": peerData.user?.id,
        },
      );
    } catch (_) {}
  }

  void checkAndUpdateReply({
    required String documentId,
    required ChatMember peerData,
    required ChatReplyMessage? message,
  }) async {
    if (message != null) {
      try {
        HapticFeedback.vibrate();
        await sl<UpdateReplyUseCase>().call(
          UpdateReplyParams(
            chatGroupId: chatGroupId,
            documentId: documentId,
            replyMessage: message,
          ),
        );
      } catch (e) {
        Logger.logMessage("Error in updateReply: ${e.toString()}");
      }
    }
  }

  @override
  void onClose() {
    // Cancel the subscription when the controller is disposed
    _leaveChat();
    _newChatSubscription?.cancel();
    if (callListener != null) callListener?.dispose();
    super.onClose();
  }
}
