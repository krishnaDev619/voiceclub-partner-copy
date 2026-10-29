import 'dart:async';

import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/query/query_message_model.dart';
import 'package:voiceclub_partner/domain/usecases/query/end_no_auth_query_session.dart';
import 'package:voiceclub_partner/domain/usecases/query/send_no_auth_query_message.dart';
import 'package:voiceclub_partner/domain/usecases/query/start_no_auth_query_session.dart';
import 'package:voiceclub_partner/domain/usecases/query/watch_no_auth_query_messages.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class NoAuthQueryController extends GetxController {
  final int accountId;
  final String source;
  final StartNoAuthQuerySessionUseCase _startSession;
  final SendNoAuthQueryMessageUseCase _sendMessage;
  final EndNoAuthQuerySessionUseCase _endSession;
  final WatchNoAuthQueryMessagesUseCase _watchMessages;

  NoAuthQueryController({
    required this.accountId,
    required this.source,
    required StartNoAuthQuerySessionUseCase startSession,
    required SendNoAuthQueryMessageUseCase sendMessage,
    required EndNoAuthQuerySessionUseCase endSession,
    required WatchNoAuthQueryMessagesUseCase watchMessages,
  }) : _startSession = startSession,
       _sendMessage = sendMessage,
       _endSession = endSession,
       _watchMessages = watchMessages;

  final messages = <QueryMessageModel>[].obs;
  final isStarting = true.obs;
  final isSending = false.obs;
  final isBotTyping = false.obs;
  final errorMessage = RxnString();

  String? _sessionId;
  StreamSubscription<List<QueryMessageModel>>? _messagesSubscription;
  Timer? _typingTimer;

  bool get canSend => _sessionId != null && !isStarting.value;

  @override
  void onReady() {
    super.onReady();
    start();
  }

  Future<void> start() async {
    if (_sessionId != null) return;

    isStarting.value = true;
    errorMessage.value = null;
    final response = await _startSession(source: source, accountId: accountId);
    isStarting.value = false;

    final sessionId = response.data?.sessionId;
    if (response.error != null || sessionId == null || sessionId.isEmpty) {
      errorMessage.value = response.errorMessage;
      return;
    }

    _sessionId = sessionId;
    await _messagesSubscription?.cancel();
    _messagesSubscription = _watchMessages(sessionId: sessionId).listen(
      _onMessagesChanged,
      onError: (_) {
        errorMessage.value = LocaleKeys.liveUnableToLoadSupportMessages.tr;
      },
    );
  }

  Future<bool> send({
    required String content,
    String? actionOptionType,
    String? actionValue,
    int? externalId,
  }) async {
    final sessionId = _sessionId;
    final trimmedContent = content.trim();
    if (sessionId == null || trimmedContent.isEmpty || isSending.value) {
      return false;
    }

    isSending.value = true;
    isBotTyping.value = true;
    errorMessage.value = null;
    final response = await _sendMessage(
      sessionId: sessionId,
      content: trimmedContent,
      accountId: accountId,
    );
    isSending.value = false;

    if (response.error != null) {
      isBotTyping.value = false;
      errorMessage.value = response.errorMessage;
      return false;
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(
      const Duration(seconds: 30),
      () => isBotTyping.value = false,
    );
    return true;
  }

  Future<void> end() async {
    final sessionId = _sessionId;
    if (sessionId != null) {
      await _endSession(sessionId: sessionId, accountId: accountId);
    }
  }

  void _onMessagesChanged(List<QueryMessageModel> updatedMessages) {
    messages.assignAll(updatedMessages);
    final latestMessage = updatedMessages.isEmpty ? null : updatedMessages.last;
    if (latestMessage?.senderType != QuerySenderType.SUPPPLY) {
      _typingTimer?.cancel();
      isBotTyping.value = false;
    }
  }

  @override
  void onClose() {
    _typingTimer?.cancel();
    _messagesSubscription?.cancel();
    super.onClose();
  }
}
