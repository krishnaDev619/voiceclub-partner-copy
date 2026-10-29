import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vibration/vibration.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/file_service.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/data/models/social/comment_model.dart';
import 'package:voiceclub_partner/data/models/social/post_model.dart';
import 'package:voiceclub_partner/data/models/social/reaction_counts_model.dart';
import 'package:voiceclub_partner/data/models/social/reply_model.dart';
import 'package:voiceclub_partner/domain/usecases/chat/upload_chat_attachment.dart';
import 'package:voiceclub_partner/domain/usecases/social/like_comment.dart';
import 'package:voiceclub_partner/domain/usecases/social/like_reply.dart';
import 'package:voiceclub_partner/domain/usecases/social/unlike_comment.dart';
import 'package:voiceclub_partner/domain/usecases/social/unlike_reply.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/learning/widgets/audio_player_widget.dart';
import 'package:voiceclub_partner/view/social/controllers/comments_controller.dart';
import 'package:voiceclub_partner/view/social/controllers/explore_controller.dart';
import 'package:voiceclub_partner/view/social/widgets/comment_item_shimmer.dart';
import 'package:voiceclub_partner/view/social/widgets/comment_sticker_bottom_sheet.dart';
import 'package:voiceclub_partner/view/social/widgets/upload_story_audio_player.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CommentsSheet extends StatefulWidget {
  final PostModel post;

  const CommentsSheet({super.key, required this.post});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet>
    with TickerProviderStateMixin {
  late final CommentsController controller;
  final TextEditingController _commentTextController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final userDetails = Get.find<UserController>().userDetails;

  String? path;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  Directory? appDirectory;
  ValueNotifier<int?> seconds = ValueNotifier<int?>(0);
  Timer? recordingTimer;
  final _recordingSeconds = 60;
  late final RecorderController recorderController;
  AnimationController? _animationController;
  bool _hasText = false;
  Worker? _callListener;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      CommentsController(postId: widget.post.id ?? '', post: widget.post),
      tag: widget.post.id ?? '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_onScroll);
    });
    _getDir();
    _initialiseControllers();
    _registerCallListener();
    _commentTextController.addListener(() {
      if (_commentTextController.text.isEmpty) {
        setState(() {
          _hasText = false;
        });
      } else {
        if (!_hasText) {
          setState(() {
            _hasText = true;
          });
        }
      }
    });
  }

  void _getDir() async {
    appDirectory = await getTemporaryDirectory();
    path = "${appDirectory?.path}/recording.m4a";
    setState(() {});
  }

  void _reupload() {
    setState(() {
      path = null;
      seconds.value = null;
      isRecording = false;
      isRecordingCompleted = false;
    });
  }

  void _initialiseControllers() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    recorderController = RecorderController();
  }

  void _registerCallListener() {
    _callListener = ever(sl<CallController>().incomingCallPayload, (
      callPayload,
    ) {
      if (callPayload.isNotEmpty && isRecording) {
        _stopRecording();
      }
    });
  }

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        _stopRecording();
      } else {
        Get.find<ExploreController>().pauseAllPlayers();
        _animationController?.forward();
        Vibration.vibrate(duration: 100);
        await recorderController.record(
          recorderSettings: RecorderSettings(
            androidEncoderSettings: AndroidEncoderSettings(
              androidEncoder: AndroidEncoder.aacLc,
            ),
            sampleRate: 44100,
            bitRate: 128000,
          ),
        );

        // Start the recordingTimer and set a callback to stop it at $recordingSeconds
        recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if ((seconds.value ?? 0) >= _recordingSeconds) {
            recordingTimer?.cancel(); // Stop the timer
            _stopRecording(); // Stop the recording
          } else {
            seconds.value = (seconds.value ?? 0) + 1;
          }
        });
      }
    } catch (_) {
    } finally {
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void _stopRecording() async {
    try {
      if (isRecording) {
        _animationController?.reverse();
        recorderController.reset();
        path = await recorderController.stop(false);

        if (path != null && (seconds.value ?? 0) >= 5) {
          isRecordingCompleted = true;
        } else if (path != null) {
          _reupload();
          Get.snackbar(
            LocaleKeys.liveAlert.tr,
            LocaleKeys.liveMinimumRecordingDurationShouldBe.tr,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          );
        }
      }

      setState(() {
        isRecording = false;
      });

      // Cancel the recording timer if it's active
      recordingTimer?.cancel();
    } catch (_) {}
  }

  void sendAudio() {
    if (path?.isNotEmpty ?? false) {
      _submitComment(
        commentType: CommentType.AUDIO,
        attachment: File(path ?? ''),
      );
      _reupload();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels < 0) {
      _scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    _scrollController.dispose();
    recorderController.dispose();
    recordingTimer?.cancel();
    _animationController?.dispose();
    _callListener?.dispose();
    super.dispose();
  }

  void _handleReply(String commentId, String userName) {
    controller.setReplyingToComment(commentId, userName);
    _commentTextController.text = '@$userName ';
    _commentTextController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentTextController.text.length),
    );
    _commentFocusNode.requestFocus();
  }

  void _toggleReplies(String commentId) {
    controller.toggleExpanded(commentId);
  }

  void _showStickerBottomSheet() {
    // Check if stickers are available
    final stickersResponse = sl<GrowthBookService>().getGrowthbookStickers();
    if (stickersResponse?.stickers?.isEmpty ?? true) {
      AlertService.showSnackBar(
        title: LocaleKeys.liveNoStickers.tr,
        subtitle: LocaleKeys.liveNoStickersAreAvailableAt.tr,
        snackBarType: SnackBarType.Warning,
      );
      return;
    }

    Get.bottomSheet(
      CommentStickerBottomSheet(
        onStickerSelected: (sticker) {
          _submitComment(
            commentType: CommentType.STICKER,
            attachmentUrl: sticker.stickerUrl ?? '',
          );
        },
        stickers: stickersResponse?.stickers ?? [],
      ),
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _submitComment({
    required CommentType commentType,
    File? attachment,
    String? attachmentUrl,
  }) async {
    try {
      final textContent = _commentTextController.text.trim();
      if (commentType == CommentType.TEXT && textContent.isEmpty) return;

      // Clear the input field
      _commentTextController.clear();
      _commentFocusNode.unfocus();

      int currentUserId = userDetails.value.user?.id ?? 0;

      if (controller.replyingToCommentId.value != null) {
        // Create a local reply immediately for responsive UX
        final newReply = ReplyModel(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          postId: widget.post.id,
          commentId: controller.replyingToCommentId.value,
          textContent: textContent,
          user: userDetails.value.user,
          createdAt: DateTime.now(),
          reactionCounts: ReactionCountsModel(like: 0),
          myReaction: null,
        );

        // Add the reply to the list and ensure the comment is expanded
        controller.toggleExpanded(controller.replyingToCommentId.value!);

        // Initialize the replies list if it doesn't exist
        if (!controller.repliesMap.containsKey(
          controller.replyingToCommentId.value,
        )) {
          controller.repliesMap[controller.replyingToCommentId.value!] =
              <ReplyModel>[].obs;
        }

        // Add the reply to the list
        final currentReplies =
            controller.repliesMap[controller.replyingToCommentId.value!] ??
            <ReplyModel>[];
        controller.repliesMap[controller.replyingToCommentId.value!] =
            currentReplies.obs;
        controller.repliesMap[controller.replyingToCommentId.value!]?.value = [
          ...currentReplies,
          newReply,
        ];

        // Update the totalReplyCount for the comment
        final commentIndex = controller.comments.indexWhere(
          (c) => c.id == controller.replyingToCommentId.value,
        );
        if (commentIndex != -1) {
          final comment = controller.comments[commentIndex];
          final updatedComment = CommentModel(
            id: comment.id,
            postId: comment.postId,
            commentType: comment.commentType,
            textContent: comment.textContent,
            mediaUrl: comment.mediaUrl,
            mostRelevantReply: comment.mostRelevantReply,
            reactionCounts: comment.reactionCounts,
            user: comment.user,
            myReaction: comment.myReaction,
            createdAt: comment.createdAt,
            totalReplyCount: (comment.totalReplyCount ?? 0) + 1,
          );
          controller.comments[commentIndex] = updatedComment;

          // Send the reply to the API without awaiting the response
          controller.createReply(
            comment: comment,
            userId: currentUserId,
            textContent: textContent,
          );
        }
      } else {
        // Create a local comment immediately for responsive UX
        final newComment = CommentModel(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          postId: widget.post.id,
          commentType: commentType,
          textContent: textContent,
          mediaUrl: attachmentUrl ?? '',
          attachment: attachment,
          user: userDetails.value.user,
          createdAt: DateTime.now(),
          reactionCounts: ReactionCountsModel(like: 0),
        );

        // Add the comment to the top of the list
        controller.comments.insert(0, newComment);

        if (attachment != null) {
          final response = await sl<UploadChatAttachmentUseCase>().call(
            UploadChatAttachmentParams(
              attachment: attachment,
              extension: FileService.getFileExtension(attachment),
            ),
          );
          if (response.data != null) {
            attachmentUrl = response.data?.url ?? '';
          }
        }

        // Send the comment to the API without awaiting the response
        controller.createComment(
          userId: currentUserId,
          commentType: commentType,
          textContent: textContent,
          mediaUrl: attachmentUrl ?? '',
        );
      }

      // Reset the reply state
      controller.clearReplyingTo();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;
    double waveformWidth = MediaQuery.of(context).size.width - 240.0;

    return DraggableScrollableSheet(
      initialChildSize: isKeyboardVisible ? 1.0 : 0.5,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      snap: true,
      shouldCloseOnMinExtent: false,
      snapSizes: const [0.5, 1.0],
      builder: (context, scrollController) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.all(2),
                      child: Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Obx(() {
                        if (controller.isLoading.value &&
                            controller.comments.isEmpty) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return const CommentItemShimmer();
                            },
                          );
                        }

                        if (controller.hasError.value &&
                            controller.comments.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(LocaleKeys.liveFailedToLoadComments.tr),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: controller.refreshComments,
                                  child: Text(LocaleKeys.liveRetry.tr),
                                ),
                              ],
                            ),
                          );
                        }

                        return NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent &&
                                !controller.isLoading.value &&
                                controller.currentPage.value <
                                    controller.totalPages.value) {
                              controller.loadMoreComments();
                            }
                            return true;
                          },
                          child:
                              controller.comments.isEmpty &&
                                      !controller.isLoading.value
                                  ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: 32,
                                        bottom:
                                            32 +
                                            Get.mediaQuery.viewInsets.bottom,
                                      ),
                                      child: Text(
                                        'No comments yet',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                  : ListView.builder(
                                    controller: scrollController,
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.all(16),
                                    itemCount:
                                        controller.comments.length +
                                        (controller.currentPage.value <
                                                controller.totalPages.value
                                            ? 1
                                            : 0),
                                    itemBuilder: (context, index) {
                                      if (index >= controller.comments.length) {
                                        return const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(
                                            child: CommentItemShimmer(),
                                          ),
                                        );
                                      }
                                      final comment =
                                          controller.comments[index];

                                      return CommentItem(
                                        comment: comment,
                                        controller: controller,
                                        post: widget.post,
                                        commentTextController:
                                            _commentTextController,
                                        commentFocusNode: _commentFocusNode,
                                        onTap:
                                            () => _toggleReplies(
                                              comment.id ?? '',
                                            ),
                                        onReply:
                                            (commentId) => _handleReply(
                                              commentId,
                                              comment.user?.name ?? 'Anonymous',
                                            ),
                                      );
                                    },
                                  ),
                        );
                      }),
                    ),
                    const SizedBox(height: 80), // Space for the input field
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                      left: 8,
                      right: 8,
                    ),
                    color: Colors.white,
                    child: Obx(() {
                      final isReplying =
                          controller.replyingToCommentId.value != null;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomProfilePicture(
                            avatarURL: userDetails.value.user?.avatar ?? '',
                            name: userDetails.value.user?.name ?? '',
                            radius: 22,
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                              ),
                                              padding:
                                                  isRecording ||
                                                          isRecordingCompleted
                                                      ? EdgeInsets.all(
                                                        isRecording
                                                            ? 12.0
                                                            : 8.0,
                                                      )
                                                      : null,
                                              child:
                                                  isRecording
                                                      ? Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            margin:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12.0,
                                                                  vertical: 8.0,
                                                                ),
                                                            height: 8.0,
                                                            width: 8.0,
                                                            decoration:
                                                                const BoxDecoration(
                                                                  shape:
                                                                      BoxShape
                                                                          .circle,
                                                                  color:
                                                                      Colors
                                                                          .red,
                                                                ),
                                                          ),
                                                          ValueListenableBuilder(
                                                            valueListenable:
                                                                seconds,
                                                            builder: (
                                                              context,
                                                              seconds,
                                                              _,
                                                            ) {
                                                              final formattedTime =
                                                                  '0:${(seconds ?? 0).toString().padLeft(2, '0')}';
                                                              return Text(
                                                                formattedTime,
                                                                style: const TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                  color:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      )
                                                      : isRecordingCompleted
                                                      ? Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              _reupload();
                                                            },
                                                            child: const Padding(
                                                              padding:
                                                                  EdgeInsets.only(
                                                                    left: 4.0,
                                                                    right: 12.0,
                                                                  ),
                                                              child: Icon(
                                                                Icons.close,
                                                                size: 28.0,
                                                                color:
                                                                    ApplicationColors
                                                                        .grey,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: UploadStoryAudioPlayer(
                                                              path: path!,
                                                              width:
                                                                  waveformWidth,
                                                              eventType:
                                                                  "chatRecordedAudio",
                                                              height: 36.0,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                      : Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (isReplying)
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 8.0,
                                                                    left: 16,
                                                                    right: 8.0,
                                                                    bottom: 4.0,
                                                                  ),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      'Replying to ${controller.replyingToUserName.value ?? ''}',
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.grey[600],
                                                                        fontSize:
                                                                            12,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8.0,
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      controller
                                                                          .clearReplyingTo();
                                                                      _commentTextController
                                                                          .clear();
                                                                    },
                                                                    child: const Icon(
                                                                      Icons
                                                                          .close,
                                                                      size: 16,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          TextField(
                                                            controller:
                                                                _commentTextController,
                                                            focusNode:
                                                                _commentFocusNode,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 13,
                                                                ),
                                                            decoration: InputDecoration(
                                                              hintText:
                                                                  !isRecording
                                                                      ? controller.replyingToCommentId.value !=
                                                                              null
                                                                          ? 'Write a reply...'
                                                                          : 'Add a comment...'
                                                                      : "",
                                                              border: OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      24,
                                                                    ),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                              filled: true,
                                                              fillColor:
                                                                  Colors
                                                                      .grey[100],
                                                              contentPadding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical: 0,
                                                                  ),
                                                              suffixIcon: Builder(
                                                                builder: (
                                                                  context,
                                                                ) {
                                                                  if (!_hasText &&
                                                                      !isRecordingCompleted) {
                                                                    return IconButton(
                                                                      icon: const Icon(
                                                                        Icons
                                                                            .attach_file_rounded,
                                                                      ),
                                                                      onPressed:
                                                                          _showStickerBottomSheet,
                                                                      iconSize:
                                                                          20,
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            4.0,
                                                                        vertical:
                                                                            8.0,
                                                                      ),
                                                                    );
                                                                  }

                                                                  return const SizedBox.shrink();
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  isReplying || _hasText || isRecordingCompleted
                                      ? GestureDetector(
                                        onTap: () {
                                          if (_hasText) {
                                            _submitComment(
                                              commentType: CommentType.TEXT,
                                            );
                                          } else if (isRecordingCompleted) {
                                            sendAudio();
                                          }
                                        },
                                        child: Container(
                                          width: 48.0,
                                          height: 48.0,
                                          padding: const EdgeInsets.only(
                                            left: 3.0,
                                          ),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Get.theme.primaryColor,
                                          ),
                                          child: Transform.rotate(
                                            angle: 5.5,
                                            child: const Icon(
                                              Icons.send_rounded,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                      : GestureDetector(
                                        onLongPress: () {
                                          _startOrStopRecording(); // Start recording when user long presses
                                        },
                                        onLongPressEnd: (_) {
                                          _startOrStopRecording(); // Stop recording when user releases the button
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: 48.0,
                                              height: 48.0,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Get.theme.primaryColor,
                                              ),
                                              child: const Icon(
                                                Icons.mic,
                                                color: Colors.white,
                                              ),
                                            ),
                                            if (isRecording)
                                              ScaleTransition(
                                                scale: Tween<double>(
                                                  begin: 1.0,
                                                  end: 3.0,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent:
                                                        _animationController!,
                                                    curve: Curves.easeInOut,
                                                  ),
                                                ),
                                                child: Container(
                                                  width: 48.0,
                                                  height: 48.0,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        Get.theme.primaryColor,
                                                  ),
                                                  child: const Icon(
                                                    Icons.mic,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CommentItem extends StatefulWidget {
  final CommentModel comment;
  final CommentsController controller;
  final TextEditingController commentTextController;
  final FocusNode commentFocusNode;
  final VoidCallback onTap;
  final Function(String) onReply;
  final PostModel post;

  const CommentItem({
    super.key,
    required this.comment,
    required this.controller,
    required this.onTap,
    required this.onReply,
    required this.post,
    required this.commentTextController,
    required this.commentFocusNode,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showMenu() {
    if (widget.post.user?.id ==
        Get.find<UserController>().userDetails.value.user?.id) {
      _showDeleteMenu();
    } else {
      _showReportMenu();
    }
  }

  void _showReportMenu() {
    try {
      HapticFeedback.vibrate();
      _overlayEntry?.remove();
      _overlayEntry = OverlayEntry(
        builder:
            (context) => Stack(
              children: [
                // Dismissible background
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _hideReportMenu,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                // Report menu
                Positioned(
                  width: 150,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    offset: const Offset(40, -40),
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () {
                          _handleReport();
                          _hideReportMenu();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 8, 54, 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag_outlined,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Report',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    } catch (_) {}
  }

  void _showDeleteMenu() {
    try {
      HapticFeedback.vibrate();
      _overlayEntry?.remove();
      _overlayEntry = OverlayEntry(
        builder:
            (context) => Stack(
              children: [
                // Dismissible background
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _hideReportMenu,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                // Report menu
                Positioned(
                  width: 150,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    offset: const Offset(40, -40),
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () {
                          _handleDelete();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 8, 54, 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    } catch (_) {}
  }

  void _hideReportMenu() {
    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } catch (_) {}
  }

  void _handleReport() {
    try {
      HapticFeedback.vibrate();
      sl<AnalyticsService>().trackEvent(
        "reportCommentPartner",
        eventProperties: widget.comment.eventProperties,
      );
      _hideReportMenu();
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Warning,
        title: LocaleKeys.liveReportComment.tr,
        subtitle: LocaleKeys.liveCommentReportedSuccessfully.tr,
      );
    } catch (_) {}
  }

  void _handleDelete() {
    try {
      HapticFeedback.vibrate();
      widget.controller.deleteComment(
        commentId: widget.comment.id ?? '',
        postId: widget.comment.postId ?? '',
      );
      _hideReportMenu();
    } catch (_) {}
  }

  void _handleLike() async {
    if (widget.comment.id == null || widget.comment.postId == null) return;

    setState(() {
      widget.comment.toggleLike();
    });

    var eventProperties = {
      ...widget.post.eventProperties,
      ...widget.comment.eventProperties,
    };

    if (widget.comment.isLiked) {
      sl<LikeCommentUsecase>().call(
        LikeCommentParams(
          commentId: widget.comment.id!,
          postId: widget.comment.postId!,
        ),
      );
      sl<AnalyticsService>().trackEvent(
        "likeCommentPartner",
        eventProperties: eventProperties,
      );
    } else {
      sl<UnlikeCommentUsecase>().call(
        UnlikeCommentParams(
          commentId: widget.comment.id!,
          postId: widget.comment.postId!,
        ),
      );
      sl<AnalyticsService>().trackEvent(
        "unlikeCommentPartner",
        eventProperties: eventProperties,
      );
    }
  }

  void _handleReplyToReply(ReplyModel reply) {
    try {
      if (reply.id != null && reply.id!.isNotEmpty) {
        // Use the controller's method to set replying to a reply
        widget.controller.setReplyingToReply(
          widget.comment.id ?? "",
          reply.id ?? "",
          reply.user?.name ?? 'Anonymous',
        );
        widget.commentTextController.text = '@${reply.user?.name} ';
        widget.commentTextController.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.commentTextController.text.length),
        );
        widget.commentFocusNode.requestFocus();
      }
    } catch (_) {}
  }

  Widget _buildCommentContent() {
    if (widget.comment.commentType == CommentType.AUDIO) {
      return AudioPlayerWidget(
        audioUrl: widget.comment.mediaUrl ?? '',
        width: MediaQuery.of(context).size.width * 0.80 - 32.0,
        attachment: widget.comment.attachment,
      );
    } else if (widget.comment.commentType == CommentType.STICKER) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 80, maxHeight: 80),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: FastCachedImage(
            url: widget.comment.mediaUrl ?? '',
            fit: BoxFit.cover,
            loadingBuilder:
                (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[100],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            errorBuilder:
                (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[100],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.comment.textContent ?? 'Sticker',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
          ),
        ),
      );
    }
    return Text(
      widget.comment.textContent ?? '',
      style: const TextStyle(fontSize: 12),
    );
  }

  @override
  void dispose() {
    _hideReportMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasReplies = (widget.comment.totalReplyCount ?? 0) > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onDoubleTap: _handleLike,
            onLongPress: _showMenu,
            child: CompositedTransformTarget(
              link: _layerLink,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomProfilePicture(
                    avatarURL: widget.comment.user?.avatar ?? '',
                    name: widget.comment.user?.name ?? '',
                    radius: 15,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.comment.user?.name ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            widget.comment.user?.tagWidget ??
                                const SizedBox.shrink(),
                            Text(
                              widget.comment.timeAgo,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        _buildCommentContent(),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => widget.onReply(widget.comment.id ?? ''),
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _handleLike,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 2),
                        Icon(
                          widget.comment.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 16,
                          color:
                              widget.comment.isLiked ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.comment.reactionCounts?.like ?? 0}',
                          style: TextStyle(
                            color:
                                (widget.comment.reactionCounts?.like ?? 0) > 0
                                    ? Colors.grey[600]
                                    : Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasReplies)
            Obx(() {
              final isExpanded = widget.controller.isExpanded(
                widget.comment.id ?? '',
              );
              final replies =
                  widget.controller.repliesMap[widget.comment.id ?? ""] ??
                  <ReplyModel>[];
              final remainingReplies =
                  (widget.comment.totalReplyCount ?? 0) - replies.length;
              final isLoadingReplies =
                  widget
                      .controller
                      .replyLoadingMap[widget.comment.id ?? ""]
                      ?.value ??
                  false;
              final hasError =
                  widget
                      .controller
                      .replyErrorMap[widget.comment.id ?? ""]
                      ?.value ??
                  false;
              return Padding(
                padding: const EdgeInsets.only(left: 44.0, top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasReplies && !isExpanded)
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 28.0,
                              height: 9.0,
                              child: Divider(
                                color: Colors.grey[300],
                                endIndent: 6,
                                height: 1,
                                thickness: 1,
                              ),
                            ),
                            Text(
                              'View ${widget.comment.totalReplyCount} ${widget.comment.totalReplyCount == 1 ? 'reply' : 'replies'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (isExpanded && hasReplies)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RepliesList(
                            key: UniqueKey(),
                            comment: widget.comment,
                            controller: widget.controller,
                            onReply: _handleReplyToReply,
                            post: widget.post,
                          ),

                          // Load more replies button
                          if (remainingReplies > 0 &&
                              !isLoadingReplies &&
                              !hasError)
                            Column(
                              children: [
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap:
                                      () => widget.controller.loadMoreReplies(
                                        widget.comment.id ?? "",
                                      ),
                                  child: Text(
                                    'View $remainingReplies more ${remainingReplies == 1 ? 'reply' : 'replies'}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class RepliesList extends StatelessWidget {
  final CommentModel comment;
  final CommentsController controller;
  final Function(ReplyModel) onReply;
  final PostModel post;

  const RepliesList({
    super.key,
    required this.comment,
    required this.controller,
    required this.onReply,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final replies = controller.repliesMap[comment.id ?? ''] ?? <ReplyModel>[];
      final isLoading =
          controller.replyLoadingMap[comment.id ?? '']?.value ?? false;
      final hasError =
          controller.replyErrorMap[comment.id ?? '']?.value ?? false;

      // Show loading indicator when loading the first page
      if (isLoading && replies.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, top: 8.0),
          child: SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.grey[400],
            ),
          ),
        );
      }

      // Show error message if there's an error and no replies
      if (hasError && replies.isEmpty) {
        return Row(
          children: [
            Text(
              'Failed to load replies',
              style: TextStyle(color: Colors.red[300], fontSize: 11),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => controller.fetchInitialReplies(comment.id ?? ''),
              child: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }

      // Return empty widget if no replies and not loading/error
      if (replies.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...replies.map(
            (reply) => ReplyItem(
              reply: reply,
              comment: comment,
              controller: controller,
              onReply: (reply) => onReply(reply),
              post: post,
            ),
          ),
          // Show loading indicator at the bottom when loading more replies
          if (isLoading && replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8.0),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey[400],
                ),
              ),
            ),
          // Show error message at the bottom when there's an error loading more replies
          if (hasError && replies.isNotEmpty)
            Row(
              children: [
                Text(
                  'Failed to load more replies',
                  style: TextStyle(color: Colors.red[300], fontSize: 11),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => controller.loadMoreReplies(comment.id ?? ''),
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.blue[600],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
        ],
      );
    });
  }
}

class ReplyItem extends StatefulWidget {
  final ReplyModel reply;
  final CommentModel comment;
  final CommentsController controller;
  final Function(ReplyModel) onReply;
  final PostModel post;

  const ReplyItem({
    super.key,
    required this.reply,
    required this.comment,
    required this.controller,
    required this.onReply,
    required this.post,
  });

  @override
  State<ReplyItem> createState() => _ReplyItemState();
}

class _ReplyItemState extends State<ReplyItem> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _showReportMenu() {
    try {
      HapticFeedback.vibrate();
      _overlayEntry?.remove();
      _overlayEntry = OverlayEntry(
        builder:
            (context) => Stack(
              children: [
                // Dismissible background
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _hideReportMenu,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                // Report menu
                Positioned(
                  width: 150,
                  child: CompositedTransformFollower(
                    link: _layerLink,
                    offset: const Offset(32, -32),
                    child: Material(
                      color: Colors.transparent,
                      child: GestureDetector(
                        onTap: () {
                          _handleReport();
                          _hideReportMenu();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 8, 54, 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag_outlined,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Report',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
      );
      Overlay.of(context).insert(_overlayEntry!);
    } catch (_) {}
  }

  void _hideReportMenu() {
    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } catch (_) {}
  }

  void _handleReport() {
    try {
      HapticFeedback.vibrate();
      sl<AnalyticsService>().trackEvent(
        "reportReplyPartner",
        eventProperties: widget.comment.eventProperties,
      );
      _hideReportMenu();
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Warning,
        title: LocaleKeys.liveReportReply.tr,
        subtitle: LocaleKeys.liveReplyReportedSuccessfully.tr,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _hideReportMenu();
    super.dispose();
  }

  void _handleLike() async {
    if (widget.reply.id == null ||
        widget.reply.commentId == null ||
        widget.reply.postId == null) {
      return;
    }

    setState(() {
      widget.reply.toggleLike();
    });

    var eventProperties = {
      ...widget.post.eventProperties,
      ...widget.comment.eventProperties,
      ...widget.reply.eventProperties,
    };

    if (widget.reply.isLiked) {
      sl<LikeReplyUsecase>().call(
        LikeReplyParams(
          replyId: widget.reply.id!,
          commentId: widget.reply.commentId!,
          postId: widget.reply.postId!,
        ),
      );
      sl<AnalyticsService>().trackEvent(
        "likeReplyPartner",
        eventProperties: eventProperties,
      );
    } else {
      sl<UnlikeReplyUsecase>().call(
        UnlikeReplyParams(
          replyId: widget.reply.id!,
          commentId: widget.reply.commentId!,
          postId: widget.reply.postId!,
        ),
      );
      sl<AnalyticsService>().trackEvent(
        "unlikeReplyPartner",
        eventProperties: eventProperties,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: _showReportMenu,
      onDoubleTap: _handleLike,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomProfilePicture(
                avatarURL: widget.reply.user?.avatar ?? '',
                name: widget.reply.user?.name ?? '',
                radius: 11,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.reply.user?.name ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        widget.reply.user?.tagWidget ?? const SizedBox.shrink(),
                        Text(
                          widget.reply.timeAgo,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.reply.textContent ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => widget.onReply(widget.reply),
                      child: Text(
                        'Reply',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Obx(() {
                // Find the current reply in the controller's list to get the latest state
                final replies =
                    widget.controller.repliesMap[widget.comment.id ?? ''] ??
                    <ReplyModel>[];
                final currentReply = replies.firstWhere(
                  (r) => r.id == widget.reply.id,
                  orElse: () => widget.reply,
                );

                return GestureDetector(
                  onTap: _handleLike,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 2),
                      Icon(
                        currentReply.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: currentReply.isLiked ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${currentReply.reactionCounts?.like ?? 0}',
                        style: TextStyle(
                          color:
                              (currentReply.reactionCounts?.like ?? 0) > 0
                                  ? Colors.grey[600]
                                  : Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
