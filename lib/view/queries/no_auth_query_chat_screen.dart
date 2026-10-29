import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/domain/usecases/query/end_no_auth_query_session.dart';
import 'package:voiceclub_partner/domain/usecases/query/send_no_auth_query_message.dart';
import 'package:voiceclub_partner/domain/usecases/query/start_no_auth_query_session.dart';
import 'package:voiceclub_partner/domain/usecases/query/watch_no_auth_query_messages.dart';
import 'package:voiceclub_partner/view/queries/controller/no_auth_query_controller.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_chat_display_widget.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_typing_indicator_bubble.dart';
import 'package:voiceclub_partner/view/queries/widget/no_auth_query_chat_bottom_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class NoAuthQueryChatScreen extends StatefulWidget {
  final int accountId;

  const NoAuthQueryChatScreen({super.key, required this.accountId});

  @override
  State<NoAuthQueryChatScreen> createState() => _NoAuthQueryChatScreenState();
}

class _NoAuthQueryChatScreenState extends State<NoAuthQueryChatScreen> {
  late final String _controllerTag;
  late final NoAuthQueryController _controller;
  final _scrollController = ScrollController();
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _controllerTag = 'blocked-support-${identityHashCode(this)}';
    _controller = Get.put(
      NoAuthQueryController(
        accountId: widget.accountId,
        source: 'BlockedAccountScreen',
        startSession: sl<StartNoAuthQuerySessionUseCase>(),
        sendMessage: sl<SendNoAuthQueryMessageUseCase>(),
        endSession: sl<EndNoAuthQuerySessionUseCase>(),
        watchMessages: sl<WatchNoAuthQueryMessagesUseCase>(),
      ),
      tag: _controllerTag,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    Get.delete<NoAuthQueryController>(tag: _controllerTag, force: true);
    super.dispose();
  }

  void _scrollToLatest(int messageCount) {
    if (messageCount == _previousMessageCount) return;
    _previousMessageCount = messageCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: const Color(0xFF2F2F2F),
        titleSpacing: 8,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF2F2F2F),
              child: Icon(Icons.support_agent, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              LocaleKeys.liveSupport.tr,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFFFFF6E0),
            image: DecorationImage(
              image: AssetImage(AssetConstants.queryChatBg),
              fit: BoxFit.cover,
            ),
          ),
          child: Obx(() {
            final messages = _controller.messages;
            final showTyping = _controller.isBotTyping.value;
            _scrollToLatest(messages.length + (showTyping ? 1 : 0));

            return Column(
              children: [
                Expanded(
                  child:
                      _controller.isStarting.value
                          ? const Center(child: CircularProgressIndicator())
                          : _controller.errorMessage.value != null &&
                              messages.isEmpty
                          ? _StartError(
                            message: _controller.errorMessage.value!,
                            onRetry: _controller.start,
                          )
                          : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: messages.length + (showTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (showTyping && index == messages.length) {
                                return const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(8, 8, 64, 2),
                                    child: QueryTypingIndicatorBubble(),
                                  ),
                                );
                              }

                              final message = messages[index];
                              final sentByMe =
                                  message.senderType == QuerySenderType.SUPPPLY;
                              final consecutive =
                                  index > 0 &&
                                  messages[index - 1].senderType ==
                                      message.senderType;
                              return QueryChatDisplayWidget(
                                key: ValueKey(message.id ?? index),
                                message: message,
                                sentByMe: sentByMe,
                                consecutive: consecutive,
                                isLatestMessage:
                                    index == messages.length - 1 && !showTyping,
                                onActionResponseSubmitted: (
                                  content,
                                  actionOptionType,
                                  actionValue,
                                  externalId,
                                ) {
                                  return _controller.send(
                                    content: content,
                                    actionOptionType: actionOptionType,
                                    actionValue: actionValue,
                                    externalId: externalId,
                                  );
                                },
                              );
                            },
                          ),
                ),
                if (_controller.errorMessage.value != null &&
                    messages.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.shade50,
                    child: Text(
                      _controller.errorMessage.value!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                NoAuthQueryChatBottomBar(
                  enabled: _controller.canSend && !_controller.isSending.value,
                  onSend: (message) => _controller.send(content: message),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _StartError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StartError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(LocaleKeys.liveTryAgain.tr),
            ),
          ],
        ),
      ),
    );
  }
}
