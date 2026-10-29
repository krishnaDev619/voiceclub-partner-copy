import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/query/query_message_model.dart';
import 'package:voiceclub_partner/data/models/query/query_session.dart';
import 'package:voiceclub_partner/data/models/query/query_session_detail.dart';
import 'package:voiceclub_partner/domain/usecases/query/end_query_session.dart';
import 'package:voiceclub_partner/domain/usecases/query/fetch_query_chat_messages_stream.dart';
import 'package:voiceclub_partner/domain/usecases/query/get_daily_query_raised_usecase.dart';
import 'package:voiceclub_partner/domain/usecases/query/get_query_session.dart';
import 'package:voiceclub_partner/domain/usecases/query/get_unseen_kam_query_chat_message_count.dart';
import 'package:voiceclub_partner/domain/usecases/query/list_query_sessions.dart';
import 'package:voiceclub_partner/domain/usecases/query/send_query_message.dart'
    as send;
import 'package:voiceclub_partner/domain/usecases/query/update_ai_call_count_usecase.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/queries/query_chat_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class QueriesController extends GetxController {
  final queries = <QuerySession>[].obs;
  RxBool isChatListLoading = false.obs;
  RxBool isLoadingMoreQueries = false.obs;
  RxBool isChatMessageLoading = false.obs;

  int _currentPage = 1;
  int _totalPages = 1;
  static const int _pageSize = 20;
  int totalQueries = 3;
  int usedQueries = 1;
  bool showQueryCountIndicator = false;

  bool get hasMorePages => _currentPage < _totalPages;
  final chats = <QueryMessageModel>[].obs;
  final sessionId = Rxn<String>();
  RxString kamName = "".obs;
  Rxn<QuerySessionStatus> querySessionStatus = Rxn<QuerySessionStatus>();
  Rxn<QuerySessionDetail> currentSessionDetails = Rxn<QuerySessionDetail>();
  final unseenKamQueryChatMessageCount = 0.obs;

  /// Set after a successful send; cleared after 5s or when a non–supply message
  /// arrives. The UI typing row also requires the latest message to be from
  /// supply — see [shouldShowQueryTypingBubble].
  final RxBool showOtherSideTypingIndicator = true.obs;

  // Controllers
  final controller = Get.find<UserController>();
  Rxn<ScrollController> scrollController = Rxn<ScrollController>();

  // use cases
  final _sendChatMessageUseCase = sl<send.SendQueryMessageUseCase>();

  // Stream subscriptions
  StreamSubscription<List<QueryDocumentSnapshot<Map<String, dynamic>>>>?
  chatStream;

  /// Firestore doc ids from the previous chat snapshot (detect truly new messages).
  final Set<String> _previousChatDocumentIds = {};

  /// Skip treating all messages as "new" on the first snapshot after subscribe.
  bool _isFirstQueryChatSnapshot = true;

  @override
  void onInit() {
    fetchAllQueries();
    fetchUnseenKamQueryChatMessageCount();
    super.onInit();
  }

  @override
  void onClose() {
    chatStream?.cancel();
    chatStream = null;
    scrollController.value?.dispose();
    super.onClose();
  }

  void _startOtherSideTypingIndicator() {
    showOtherSideTypingIndicator.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
  }

  /// Typing bubble is only shown when waiting for a reply **and** the latest
  /// chat message is from the supply user (not BOT / KAM / SYSTEM).
  bool shouldShowQueryTypingBubble(List<QueryMessageModel> messages) {
    if (!showOtherSideTypingIndicator.value) return false;
    if (messages.isEmpty) return true;
    return messages.last.senderType == QuerySenderType.SUPPPLY;
  }

  void createSession({required String source}) async {
    var querySessionResponse = await controller.fetchQuerySession(
      source: source,
    );
    if (querySessionResponse?.sessionId != null) {
      setupSession(currentSessionId: querySessionResponse?.sessionId ?? "");
    } else {
      showQueryCountIndicator = true;
      update();
    }
  }

  void scrollToBottom() {
    if (scrollController.value?.hasClients ?? false) {
      scrollController.value?.animateTo(
        scrollController.value?.position.maxScrollExtent ?? 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void fetchUnseenKamQueryChatMessageCount() async {
    final response = await sl<GetUnseenKamQueryChatMessageCountUseCase>().call(
      NoParams(),
    );
    if (response.data != null) {
      unseenKamQueryChatMessageCount.value =
          response.data?.kamMessageCount ?? 0;
    }
  }

  void fetchAllQueries() async {
    isChatListLoading.value = true;
    _currentPage = 1;
    _totalPages = 1;

    final response = await sl<ListQuerySessionsUseCase>().call(
      ListQuerySessionsParams(page: 1, pageSize: _pageSize),
    );

    if (response.data != null) {
      queries.value = response.data?.sessions ?? [];
      _currentPage = response.data?.page ?? 1;
      _totalPages = response.data?.totalPages ?? 1;
    }
    isChatListLoading.value = false;
  }

  void fetchMoreQueries() async {
    if (!hasMorePages || isLoadingMoreQueries.value) return;

    isLoadingMoreQueries.value = true;
    final nextPage = _currentPage + 1;

    final response = await sl<ListQuerySessionsUseCase>().call(
      ListQuerySessionsParams(page: nextPage, pageSize: _pageSize),
    );

    if (response.data != null) {
      queries.addAll(response.data?.sessions ?? []);
      _currentPage = response.data?.page ?? nextPage;
      _totalPages = response.data?.totalPages ?? _totalPages;
    }
    isLoadingMoreQueries.value = false;
  }

  Future<void> fetchQueryChatMessages(String sessionId) async {
    try {
      // Cancel any existing stream subscription to prevent memory leaks
      await chatStream?.cancel();
      chatStream = null;

      _previousChatDocumentIds.clear();
      _isFirstQueryChatSnapshot = true;

      this.sessionId.value = sessionId;
      final streamResponse = await sl<FetchQueryChatMessagesStreamUseCase>()
          .call(FetchQueryChatMessagesStreamParams(sessionId: sessionId));
      chatStream = streamResponse.listen(
        _onQueryChatMessagesSnapshot,
        onError: (error) {
          Logger.logMessage(error.toString());
        },
        onDone: () {
          Logger.logMessage('Chat messages fetched');
        },
      );
    } catch (e, st) {
      Logger.logMessage('fetchQueryChatMessages failed: $e');
      Logger.logMessage(st.toString());
    }
  }

  /// Parses a Firestore chat document; keeps list length/order on failure.
  QueryMessageModel _queryMessageFromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    try {
      return QueryMessageModel.fromJson(doc.data());
    } catch (e, st) {
      Logger.logMessage('Query chat doc ${doc.id} parse error: $e');
      Logger.logMessage(st.toString());
      return QueryMessageModel(id: doc.id, content: '');
    }
  }

  void _onQueryChatMessagesSnapshot(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> data,
  ) {
    try {
      final currentIds = data.map((e) => e.id).toSet();

      if (_isFirstQueryChatSnapshot) {
        _isFirstQueryChatSnapshot = false;
        _previousChatDocumentIds
          ..clear()
          ..addAll(currentIds);
        chats.value = data.map(_queryMessageFromDocument).toList();
        scrollToBottom();
        return;
      }

      final newDocIds = currentIds.difference(_previousChatDocumentIds);
      _previousChatDocumentIds
        ..clear()
        ..addAll(currentIds);

      var hasNewSystemMessage = false;

      for (final doc in data) {
        if (!newDocIds.contains(doc.id)) continue;
        final model = _queryMessageFromDocument(doc);
        if (model.senderType == QuerySenderType.SYSTEM) {
          hasNewSystemMessage = true;
        }
      }

      chats.value = data.map(_queryMessageFromDocument).toList();
      scrollToBottom();

      if (hasNewSystemMessage) {
        final sid = sessionId.value;
        if (sid != null && sid.isNotEmpty) {
          unawaited(_refreshKamNameFromQuerySession(sid));
        }
      }
    } catch (e, st) {
      Logger.logMessage('_onQueryChatMessagesSnapshot failed: $e');
      Logger.logMessage(st.toString());
    }
  }

  Future<void> _refreshKamNameFromQuerySession(String sessionId) async {
    try {
      final response = await sl<GetQuerySessionUseCase>().call(
        GetQuerySessionParams(sessionId: sessionId),
      );

      if (this.sessionId.value != sessionId) {
        return;
      }

      if (response.error != null) {
        Logger.logMessage(
          'GetQuerySession after SYSTEM message: ${response.errorMessage}',
        );
        return;
      }

      final session = response.data?.session;
      if (session != null) {
        currentSessionDetails.value = session;
        kamName.value = session.kamName ?? '';
        querySessionStatus.value = session.status;
      }
    } catch (e, st) {
      Logger.logMessage('_refreshKamNameFromQuerySession failed: $e');
      Logger.logMessage(st.toString());
    }
  }

  void stopQueryChatMessages() {
    chatStream?.cancel();
    chats.clear();
    chatStream = null;
    sessionId.value = "";
    chats.clear();
    sessionId.value = "";
    kamName.value = "";
    querySessionStatus.value = null;
    currentSessionDetails.value = null;
    isChatMessageLoading.value = false;
    _previousChatDocumentIds.clear();
    _isFirstQueryChatSnapshot = true;
  }

  Future<bool> getSessionDetails(String sessionId) async {
    try {
      final response = await sl<GetQuerySessionUseCase>().call(
        GetQuerySessionParams(sessionId: sessionId),
      );
      if (response.error != null) {
        Logger.logMessage('getSessionDetails failed: ${response.errorMessage}');
        return false;
      }
      if (response.data != null) {
        currentSessionDetails.value = response.data?.session;
        return true;
      }
      return false;
    } catch (e, st) {
      Logger.logMessage('getSessionDetails exception: $e');
      Logger.logMessage(st.toString());
      return false;
    }
  }

  Future<void> setupSession({required String currentSessionId}) async {
    sessionId.value = currentSessionId;
    final isSessionDetailsAvailable = await getSessionDetails(currentSessionId);
    if (isSessionDetailsAvailable) {
      kamName.value = currentSessionDetails.value?.kamName ?? "";
      querySessionStatus.value = currentSessionDetails.value?.status;
      await fetchQueryChatMessages(currentSessionId);
    }
    getDailyQueryRaisedCount(showQueryCountIndicator: true);
  }

  Future<void> sendMessage({
    required QueryMessageType messageType,
    String? content,
    File? attachment,
    String? actionOptionType,
    String? actionValue,
    int? externalId,
  }) async {
    try {
      if (attachment != null) {
        final isValid = await _checkAttachmentSize(attachment, messageType);
        if (!isValid) {
          return;
        }
        //show the loader while uploading the attachments
        Get.context?.loaderOverlay.show();
      }

      final response = await _sendChatMessageUseCase.call(
        send.SendQueryMessageParams(
          sessionId: sessionId.value!,
          content: content,
          messageType: messageType,
          attachment: attachment,
          actionOptionType: actionOptionType,
          actionValue: actionValue,
          externalId: externalId,
        ),
      );
      if (response.error?.response?.statusCode == 415 &&
          sessionId.value?.isNotEmpty == true) {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.liveMessageNotSent.tr,
          subtitle: LocaleKeys.liveCannotBeSentToBot.trParams({
            'type': _attachmentTypeLabel(messageType),
          }),
        );
      } else {
        if (response.error == null) {
          _startOtherSideTypingIndicator();
        }
        if (response.error?.response?.statusCode == 422 &&
            sessionId.value?.isNotEmpty == true) {
          getSessionDetails(sessionId.value!);
        }
      }
    } catch (_) {
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }

  String _attachmentTypeLabel(QueryMessageType messageType) {
    switch (messageType) {
      case QueryMessageType.TEXT:
        return LocaleKeys.liveText.tr;
      case QueryMessageType.AUDIO:
        return LocaleKeys.liveAudio.tr;
      case QueryMessageType.IMAGE:
        return LocaleKeys.liveImage.tr;
      case QueryMessageType.VIDEO:
        return LocaleKeys.liveQueryVideo.tr;
    }
  }

  Future<bool> _checkAttachmentSize(
    File file,
    QueryMessageType messageType,
  ) async {
    final sizeInBytes = await file.length();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    if (sizeInMB >= 50) {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.errorTitle.tr,
        subtitle: LocaleKeys.liveSizeIsTooLarge.trParams({
          'type': _attachmentTypeLabel(messageType),
        }),
      );
      return false;
    }
    return true;
  }

  Future<void> callKAM() async {
    final url = Uri.parse(
      'tel:0${controller.userDetails.value.kamPhone?.trim()}',
    );
    if (await canLaunchUrl(url)) {
      await updateAiCallCount();
      sl<AnalyticsService>().trackEvent(
        'kamCallPlaced',
        eventProperties: {
          'kamName': kamName.value,
          'kamPhone': controller.userDetails.value.kamPhone,
          'isAgentOnCall': controller.userDetails.value.isBotKamNumber ?? false,
        },
      );
      await launchUrl(url);
    }
  }

  Future<void> updateAiCallCount() async {
    try {
      await sl<UpdateAiCallCountUseCase>().call(
        UpdateAiCallCountParams(sessionId: sessionId.value!),
      );
    } catch (e) {
      Logger.logMessage('updateAiCallCount failed: $e');
    }
  }

  void endQuerySession() async {
    await sl<EndQuerySessionUseCase>().call(
      EndQuerySessionParams(sessionId: sessionId.value!),
    );
    Get.back();
  }

  Future<void> navigateToAllQueryChatScreen({required String source}) async {
    final response = await sl<GetDailyQueryRaisedCountUseCase>().call(
      NoParams(),
    );
    if (response.data != null) {
      totalQueries = response.data?.dailyQueryLimit ?? 3;
      usedQueries = response.data?.dailyQueryRaisedCount ?? 0;

      if (usedQueries >= totalQueries) {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.errorTitle.tr,
          subtitle: LocaleKeys.liveYouHaveReachedTheDaily.tr,
        );
        return;
      }
      Get.to(() => QueryChatScreen(source: source));
    } else {
      Logger.logMessage(
        'getQueryRaisedCount failed: ${response.error?.message}',
      );
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.errorTitle.tr,
        subtitle: LocaleKeys.liveFailedToOpenQueryChat.tr,
      );
    }
  }

  Future<void> navigateToQueryChatScreenFromHome({
    required String source,
  }) async {
    //Fetch the pending or ongoing query sessions
    String? pendingOrOngoingQuerySessionId;
    final listQuerySessionsResponse = await sl<ListQuerySessionsUseCase>().call(
      ListQuerySessionsParams(page: 1, pageSize: 5),
    );

    if (listQuerySessionsResponse.data != null) {
      List<QuerySession>? sessions =
          listQuerySessionsResponse.data?.sessions ?? [];

      if (sessions.isNotEmpty) {
        try {
          pendingOrOngoingQuerySessionId =
              sessions
                  .firstWhere(
                    (session) =>
                        session.status == QuerySessionStatus.PENDING ||
                        session.status == QuerySessionStatus.ONGOING,
                  )
                  .sessionId ??
              '';
        } catch (e) {
          Logger.logMessage(
            'Error getting pending or ongoing query session id: $e',
          );
        }
      }
    }

    if (pendingOrOngoingQuerySessionId != null) {
      Get.to(
        () => QueryChatScreen(
          source: source,
          sessionId: pendingOrOngoingQuerySessionId,
        ),
      );
      return;
    }

    //If no pending or ongoing query session is found, then navigate to all query chat screen, creating the new query session.
    final response = await sl<GetDailyQueryRaisedCountUseCase>().call(
      NoParams(),
    );
    if (response.data != null) {
      totalQueries = response.data?.dailyQueryLimit ?? 3;
      usedQueries = response.data?.dailyQueryRaisedCount ?? 0;

      if (usedQueries >= totalQueries) {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.errorTitle.tr,
          subtitle: LocaleKeys.liveYouHaveReachedTheDaily.tr,
        );
        return;
      }
      Get.to(() => QueryChatScreen(source: source));
    } else {
      Logger.logMessage(
        'getQueryRaisedCount failed: ${response.error?.message}',
      );
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.errorTitle.tr,
        subtitle: LocaleKeys.liveFailedToOpenQueryChat.tr,
      );
    }
  }

  Future<void> getDailyQueryRaisedCount({
    bool showQueryCountIndicator = false,
  }) async {
    final response = await sl<GetDailyQueryRaisedCountUseCase>().call(
      NoParams(),
    );
    if (response.data != null) {
      totalQueries = response.data?.dailyQueryLimit ?? 3;
      usedQueries = response.data?.dailyQueryRaisedCount ?? 0;
      this.showQueryCountIndicator = showQueryCountIndicator;
      update();
    }
  }

  void hideQueryCountIndicator() {
    showQueryCountIndicator = false;
    update();
  }
}
