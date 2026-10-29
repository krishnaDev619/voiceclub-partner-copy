import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/query/query_message_model.dart';
import 'package:voiceclub_partner/view/chat/widgets/date_separator.dart';
import 'package:voiceclub_partner/view/queries/controller/queries_controller.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_chat_display_widget.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_system_message.dart';
import 'package:voiceclub_partner/view/queries/widget/messages/query_typing_indicator_bubble.dart';
import 'package:voiceclub_partner/view/queries/widget/query_chat_bottom_bar.dart';
import 'package:voiceclub_partner/view/queries/widget/query_count_indicator_widget.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class QueryChatScreen extends StatefulWidget {
  final QuerySessionStatus? querySessionStatus;
  final String? sessionId;
  final String source;

  const QueryChatScreen({
    super.key,
    this.querySessionStatus,
    this.sessionId,
    required this.source,
  });

  @override
  State<QueryChatScreen> createState() => _QueryChatScreenState();
}

class _QueryChatScreenState extends State<QueryChatScreen> {
  final QueriesController _controller = Get.find<QueriesController>();
  int _previousMessageCount = 0;

  @override
  initState() {
    super.initState();
    _controller.hideQueryCountIndicator();
    if (widget.sessionId == null) {
      _controller.createSession(source: widget.source);
    } else {
      _controller.setupSession(currentSessionId: widget.sessionId!);
    }
    _controller.scrollController.value = ScrollController();
    _previousMessageCount = 0;
    _controller.querySessionStatus.value = widget.querySessionStatus;
  }

  @override
  void dispose() {
    _controller.stopQueryChatMessages();
    _controller.scrollController.value?.dispose();
    _controller.scrollController.value = null;
    super.dispose();
  }

  bool _shouldShowDateSeparator(DateTime prevDate, DateTime currentDate) {
    final prev = DateTime(prevDate.year, prevDate.month, prevDate.day);
    final current = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );
    return prev != current;
  }

  /// Check if the message is consecutive from the same sender
  bool _isConsecutive(List<QueryMessageModel> messages, int index) {
    if (index == messages.length - 1) return false;

    final currentMessage = messages[index];
    final previousMessage = messages[index + 1];

    return currentMessage.senderType == previousMessage.senderType;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSessionDetails = _controller.currentSessionDetails.value;
      final messageAllowed = currentSessionDetails?.messageAllowed;
      final latestMessage =
          _controller.chats.isNotEmpty ? _controller.chats.last : null;
      final latestMessageIsFromBot =
          latestMessage != null &&
          latestMessage.senderType != QuerySenderType.SUPPPLY &&
          latestMessage.senderType != QuerySenderType.SYSTEM;
      final nonUserMsgs =
          _controller.chats
              .where((m) => m.senderType != QuerySenderType.SUPPPLY)
              .toList();
      final lastNonUserMessage =
          nonUserMsgs.isNotEmpty ? nonUserMsgs.last : null;
      final lastNonUserIsSystemOrKam =
          lastNonUserMessage?.senderType == QuerySenderType.SYSTEM ||
          lastNonUserMessage?.senderType == QuerySenderType.KAM;
      final showKeyboard =
          (lastNonUserIsSystemOrKam && messageAllowed == true) ||
          (latestMessage?.senderType == QuerySenderType.SYSTEM &&
              messageAllowed == true) ||
          (latestMessageIsFromBot &&
              !(latestMessage.actionType?.trim().isNotEmpty ?? false) &&
              (messageAllowed == true));
      final callAllowed = currentSessionDetails?.callAllowed;
      final status = currentSessionDetails?.status;
      String kamName =
          _controller.kamName.value.isEmpty
              ? LocaleKeys.liveSupport.tr
              : _controller.kamName.value;
      String outsideWorkingHourMessage =
          currentSessionDetails?.workingHourMessage ?? "";
      final endButtonAllowed = currentSessionDetails?.endButtonAllowed;

      return Scaffold(
        backgroundColor: const Color(0xFFFFF6F6),
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0.0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          leadingWidth: 32.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: const BackButton(color: Color(0xFF2F2F2F)),
          ),
          actions: [
            if (callAllowed == true)
              IconButton(
                onPressed: () {
                  _controller.callKAM();
                },
                padding: const EdgeInsets.only(right: 12.0),
                icon: const Icon(Icons.call),
              ),
            if (endButtonAllowed == true)
              GestureDetector(
                onTap: () {
                  _controller.endQuerySession();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: ApplicationColors.errorColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(top: 12, bottom: 12, right: 18),
                  child: Center(
                    child: Text(
                      LocaleKeys.liveEnd.tr,
                      style: TextStyle(color: ApplicationColors.errorColor),
                    ),
                  ),
                ),
              ),
          ],
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xFF2F2F2F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.support_agent,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kamName.isEmpty ? LocaleKeys.liveSupport.tr : kamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2F2F2F),
                      ),
                    ),
                    Obx(() {
                      if (_controller.querySessionStatus.value != null) {
                        return Text(
                          LocaleKeys.liveStatusQuery.trParams({
                            'status':
                                _controller.querySessionStatus.value
                                    ?.toQuerySessionStatusName() ??
                                '',
                          }),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                widget.querySessionStatus ==
                                        QuerySessionStatus.REJECTED
                                    ? Color(0xFFEB4646)
                                    : Color(0xFF979797),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: GetBuilder<QueriesController>(
            builder: (controller) {
              return Stack(
                children: [
                  // Background
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF6E0),
                      image: DecorationImage(
                        image: AssetImage(AssetConstants.queryChatBg),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Chat content
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        SizedBox(height: 10.0),
                        Expanded(
                          child: StreamBuilder<List<QueryMessageModel>>(
                            stream: controller.chats.stream,
                            builder: (context, snapshot) {
                              final messages = snapshot.data?.toList() ?? [];
                              final showTypingBubble =
                                  !lastNonUserIsSystemOrKam &&
                                  _controller.shouldShowQueryTypingBubble(
                                    messages,
                                  );

                              if (messages.isEmpty &&
                                  !showTypingBubble &&
                                  _controller.isChatMessageLoading.value ==
                                      false) {
                                return Center(
                                  child: QueryTicketAndStatusMessage(
                                    status: status,
                                  ),
                                );
                              }

                              // Scroll to bottom when messages first load or new messages arrive
                              final currentMessageCount = messages.length;
                              final hasNewMessages =
                                  currentMessageCount != _previousMessageCount;

                              if (hasNewMessages) {
                                _previousMessageCount = currentMessageCount;
                                // Use a small delay to ensure ListView is fully built
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () {
                                      if (mounted) {
                                        _controller.scrollToBottom();
                                      }
                                    },
                                  );
                                });
                              }

                              final typingExtra = showTypingBubble ? 1 : 0;

                              return ListView.builder(
                                itemCount: messages.length + typingExtra,
                                controller: controller.scrollController.value,
                                shrinkWrap: true,
                                reverse: false,
                                padding: const EdgeInsets.only(
                                  bottom: 100.0,
                                  top: 10.0,
                                ),
                                itemBuilder: (context, index) {
                                  if (showTypingBubble &&
                                      index == messages.length) {
                                    final sidePad =
                                        MediaQuery.of(context).size.width *
                                        0.15;
                                    return Container(
                                      margin: EdgeInsets.only(
                                        top: 8.0,
                                        bottom: 2.0,
                                        left: 8.0,
                                        right: sidePad,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: const QueryTypingIndicatorBubble(),
                                    );
                                  }

                                  final prevMessage =
                                      index > 0 ? messages[index - 1] : null;
                                  final message = messages[index];
                                  final sentByMe =
                                      message.senderType ==
                                      QuerySenderType.SUPPPLY;
                                  final showDateSeparator =
                                      index == 0 ||
                                      (prevMessage?.createdAt != null &&
                                              message.createdAt != null
                                          ? _shouldShowDateSeparator(
                                            prevMessage!.createdAt!,
                                            message.createdAt!,
                                          )
                                          : false);

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (showDateSeparator &&
                                          message.createdAt != null)
                                        DateSeparator(
                                          messages[messages.length > 1 &&
                                                      index + 1 <
                                                          messages.length
                                                  ? index + 1
                                                  : index]
                                              .createdAt!,
                                          isQueryChat: true,
                                          bottomPadding: index == 0 ? 8 : null,
                                        ),

                                      if (index == 0)
                                        QueryTicketAndStatusMessage(
                                          ticketId:
                                              currentSessionDetails?.id
                                                  ?.toString()
                                                  .padLeft(6, '0') ??
                                              '',
                                          topPadding: index == 0 ? 0 : null,
                                        ),

                                      QueryChatDisplayWidget(
                                        key: ValueKey(message.id),
                                        message: message,
                                        sentByMe: sentByMe,
                                        consecutive: _isConsecutive(
                                          messages,
                                          index,
                                        ),
                                        isLatestMessage:
                                            index == messages.length - 1 &&
                                            !showTypingBubble,
                                        onActionResponseSubmitted: (
                                          content,
                                          actionOptionType,
                                          actionValue,
                                          externalId,
                                        ) async {
                                          await _controller.sendMessage(
                                            messageType: QueryMessageType.TEXT,
                                            content: content,
                                            actionOptionType: actionOptionType,
                                            actionValue: actionValue,
                                            externalId: externalId,
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        if (status != QuerySessionStatus.ONGOING &&
                            showKeyboard == false)
                          QueryTicketAndStatusMessage(status: status),
                        if ((status == QuerySessionStatus.ONGOING ||
                                status == QuerySessionStatus.PENDING) &&
                            outsideWorkingHourMessage.isNotEmpty)
                          SystemMessage(
                            message: outsideWorkingHourMessage,
                            margin: EdgeInsets.only(
                              bottom: showKeyboard == true ? 12.0 : 20.0,
                              top:
                                  status != QuerySessionStatus.ONGOING
                                      ? 4.0
                                      : 12.0,
                            ),
                          ),
                        if (showKeyboard == true) const QueryChatBottomBar(),
                      ],
                    ),
                  ),
                  //Current Query count indicator
                  QueryCountIndicatorWidget(),
                  // Loading indicator
                  Obx(() {
                    return Visibility(
                      visible: _controller.isChatMessageLoading.value,
                      child: const Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16.0,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Color(0xFF25D366),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}
