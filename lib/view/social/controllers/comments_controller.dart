import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/social/comment_model.dart';
import 'package:voiceclub_partner/data/models/social/post_model.dart';
import 'package:voiceclub_partner/data/models/social/reply_model.dart';
import 'package:voiceclub_partner/domain/usecases/social/create_comment.dart';
import 'package:voiceclub_partner/domain/usecases/social/create_reply.dart';
import 'package:voiceclub_partner/domain/usecases/social/delete_comment.dart';
import 'package:voiceclub_partner/domain/usecases/social/list_comments.dart';
import 'package:voiceclub_partner/domain/usecases/social/list_replies.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class CommentsController extends GetxController {
  final String postId;
  final PostModel post;

  CommentsController({required this.postId, required this.post});

  // Comments state
  final comments = <CommentModel>[].obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final totalPages = 1.obs;
  final currentPage = 1.obs;

  // For reply state management
  final replyingToCommentId = RxnString();
  final replyingToReplyId = RxnString();
  final replyingToUserName = RxnString();

  // For replies - using RxMap for better reactivity
  final repliesMap = <String, RxList<ReplyModel>>{}.obs;
  final replyLoadingMap = <String, RxBool>{}.obs;
  final replyErrorMap = <String, RxBool>{}.obs;
  final replyTotalPagesMap = <String, RxInt>{}.obs;
  final replyCurrentPagesMap = <String, RxInt>{}.obs;

  // Track expanded comments
  final expandedComments = <String>{}.obs;

  @override
  void onInit() {
    fetchInitialComments();
    super.onInit();
  }

  // Set reply state
  void setReplyingToComment(String commentId, String userName) {
    replyingToCommentId.value = commentId;
    replyingToReplyId.value = null;
    replyingToUserName.value = userName;
  }

  // Set reply to a reply (which is actually a reply to the comment)
  void setReplyingToReply(String commentId, String replyId, String userName) {
    replyingToCommentId.value = commentId;
    replyingToReplyId.value = replyId;
    replyingToUserName.value = userName;
  }

  // Clear reply state
  void clearReplyingTo() {
    replyingToCommentId.value = null;
    replyingToReplyId.value = null;
    replyingToUserName.value = null;
  }

  // Toggle expanded state for a comment
  void toggleExpanded(String commentId) {
    if (expandedComments.contains(commentId)) {
      expandedComments.remove(commentId);
    } else {
      expandedComments.add(commentId);

      // Only fetch replies if they haven't been loaded yet
      if (!repliesMap.containsKey(commentId) ||
          (repliesMap[commentId]?.isEmpty ?? true)) {
        fetchInitialReplies(commentId);
      }
    }
  }

  // Check if a comment is expanded
  bool isExpanded(String commentId) {
    return expandedComments.contains(commentId);
  }

  Future<void> fetchInitialComments() async {
    currentPage.value = 1;
    totalPages.value = 1;
    comments.clear();
    await fetchComments(page: 1);
  }

  Future<void> fetchComments({required int page}) async {
    if (page <= totalPages.value) {
      isLoading.value = true;
      if (page == 1) {
        comments.clear();
      }

      try {
        hasError.value = false;
        final response = await sl<ListCommentsUsecase>().call(
          ListCommentsParams(postId: postId, page: page, pageSize: 20),
        );

        if (response.data != null) {
          totalPages.value = response.data?.totalPages ?? 1;
          final newComments = response.data?.comments ?? [];

          // If it's the first page and we have a local comment at the top,
          // preserve it and add the new comments after it
          if (page == 1 &&
              comments.isNotEmpty &&
              comments.first.id?.startsWith('temp-') == true) {
            final localComment = comments.first;
            comments.clear();
            comments.add(localComment);
            comments.addAll(newComments);
          } else {
            comments.addAll(newComments);
          }

          currentPage.value = page;
        } else if (response.error != null) {
          hasError.value = true;
          AlertService.showSnackBar(
            title: LocaleKeys.errorTitle.tr,
            subtitle: LocaleKeys.liveFailedToFetchComments.tr,
            snackBarType: SnackBarType.Error,
          );
        }
      } catch (e) {
        hasError.value = true;
        Logger.logMessage('Error fetching comments: ${e.toString()}');
        AlertService.showSnackBar(
          title: LocaleKeys.errorTitle.tr,
          subtitle: LocaleKeys.liveSomethingWentWrongDetail.trParams({
            'detail': e.toString(),
          }),
          snackBarType: SnackBarType.Error,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMoreComments() async {
    if (!isLoading.value && currentPage.value < totalPages.value) {
      await fetchComments(page: currentPage.value + 1);
    }
  }

  Future<void> refreshComments() async {
    await fetchInitialComments();
  }

  // Replies handling
  Future<void> fetchInitialReplies(String commentId) async {
    // Initialize reactive state for this comment if not already done
    _initializeReactiveStateForComment(commentId);

    // Reset pagination state
    replyCurrentPagesMap[commentId]?.value = 0;
    replyTotalPagesMap[commentId]?.value = 1;
    replyErrorMap[commentId]?.value = false;

    // Set loading state before fetching
    replyLoadingMap[commentId]?.value = true;

    // Fetch the first page of replies
    await fetchReplies(commentId: commentId, page: 1);
  }

  // Initialize reactive state for a comment
  void _initializeReactiveStateForComment(String commentId) {
    if (!repliesMap.containsKey(commentId)) {
      repliesMap[commentId] = <ReplyModel>[].obs;
    }

    if (!replyLoadingMap.containsKey(commentId)) {
      replyLoadingMap[commentId] = false.obs;
    }

    if (!replyErrorMap.containsKey(commentId)) {
      replyErrorMap[commentId] = false.obs;
    }

    if (!replyTotalPagesMap.containsKey(commentId)) {
      replyTotalPagesMap[commentId] = 1.obs;
    }

    if (!replyCurrentPagesMap.containsKey(commentId)) {
      replyCurrentPagesMap[commentId] = 0.obs;
    }
  }

  Future<void> fetchReplies({
    required String commentId,
    required int page,
  }) async {
    // Initialize reactive state for this comment if not already done
    _initializeReactiveStateForComment(commentId);

    // Set loading state
    replyLoadingMap[commentId]?.value = true;

    // For first page, reset error state
    if (page == 1) {
      replyErrorMap[commentId]?.value = false;

      // Don't clear replies if we have local ones
      final existingReplies = repliesMap[commentId] ?? [];
      if (!existingReplies.any((r) => r.id?.startsWith('temp-') == true)) {
        repliesMap[commentId]?.clear();
      }
    }

    try {
      final response = await sl<ListRepliesUsecase>().call(
        ListRepliesParams(
          postId: postId,
          commentId: commentId,
          page: page,
          pageSize: 10,
        ),
      );

      if (response.data != null) {
        // Update pagination info
        replyTotalPagesMap[commentId]?.value = response.data?.totalPages ?? 1;
        replyCurrentPagesMap[commentId]?.value = page;

        // Get new replies from response
        final newReplies = response.data?.replies ?? [];
        final currentReplies = repliesMap[commentId] ?? [];

        // If we have local replies, preserve them at the bottom
        if (currentReplies.any((r) => r.id?.startsWith('temp-') == true)) {
          final localReplies =
              currentReplies
                  .where((r) => r.id?.startsWith('temp-') == true)
                  .toList();
          final existingReplies =
              currentReplies.where((r) => !r.id!.startsWith('temp-')).toList();

          // Update the list reactively
          repliesMap[commentId]?.assignAll([
            ...existingReplies,
            ...newReplies,
            ...localReplies,
          ]);
        } else {
          // Update the list reactively
          repliesMap[commentId]?.assignAll([...currentReplies, ...newReplies]);
        }

        replyErrorMap[commentId]?.value = false;
      } else if (response.error != null) {
        replyErrorMap[commentId]?.value = true;
        Logger.logMessage('Error fetching replies: ${response.error}');
        AlertService.showSnackBar(
          title: LocaleKeys.errorTitle.tr,
          subtitle: LocaleKeys.liveFailedToFetchReplies.tr,
          snackBarType: SnackBarType.Error,
        );
      }
    } catch (e) {
      replyErrorMap[commentId]?.value = true;
      Logger.logMessage('Error fetching replies: ${e.toString()}');
      AlertService.showSnackBar(
        title: LocaleKeys.errorTitle.tr,
        subtitle: LocaleKeys.liveSomethingWentWrongDetail.trParams({
          'detail': e.toString(),
        }),
        snackBarType: SnackBarType.Error,
      );
    } finally {
      // Always update loading state to false after API call completes
      replyLoadingMap[commentId]?.value = false;
    }
  }

  Future<void> loadMoreReplies(String commentId) async {
    // Initialize reactive state for this comment if not already done
    _initializeReactiveStateForComment(commentId);

    // Prevent duplicate requests
    if (replyLoadingMap[commentId]?.value == true) {
      Logger.logMessage(
        'Already loading replies for comment $commentId, skipping request',
      );
      return;
    }

    // Check if we have more pages to load
    final currentPage = replyCurrentPagesMap[commentId]?.value ?? 0;
    final totalPages = replyTotalPagesMap[commentId]?.value ?? 0;

    if (currentPage < totalPages) {
      Logger.logMessage(
        'Loading more replies for comment $commentId, page ${currentPage + 1} of $totalPages',
      );
      await fetchReplies(commentId: commentId, page: currentPage + 1);
    } else {
      Logger.logMessage('No more replies to load for comment $commentId');
    }
  }

  Future<void> refreshReplies(String commentId) async {
    await fetchInitialReplies(commentId);
  }

  Future<void> deleteComment({
    required String commentId,
    required String postId,
  }) async {
    try {
      // Don't set loading state since we're not awaiting the response
      // isLoading(true);

      // Fire and forget - don't await the response
      sl<DeleteCommentUsecase>()
          .call(DeleteCommentParams(postId: postId, commentId: commentId))
          .then((response) {
            if (response.error != null) {
              AlertService.showSnackBar(
                title: LocaleKeys.errorTitle.tr,
                subtitle: LocaleKeys.liveFailedToDeleteComment.tr,
                snackBarType: SnackBarType.Error,
              );
            } else {
              comments.removeWhere((comment) => comment.id == commentId);
              sl<AnalyticsService>().trackEvent(
                "deleteCommentPartner",
                eventProperties: {...post.eventProperties},
              );
            }
          })
          .catchError((e) {
            Logger.logMessage('Error deleting comment: ${e.toString()}');
            AlertService.showSnackBar(
              title: LocaleKeys.errorTitle.tr,
              subtitle: LocaleKeys.liveSomethingWentWrongDetail.trParams({
                'detail': e.toString(),
              }),
              snackBarType: SnackBarType.Error,
            );
          });

      // No need to refresh comments since we're adding them locally
      // fetchInitialComments();
    } catch (e) {
      Logger.logMessage('Error creating comment: ${e.toString()}');
      AlertService.showSnackBar(
        title: LocaleKeys.errorTitle.tr,
        subtitle: LocaleKeys.liveSomethingWentWrongDetail.trParams({
          'detail': e.toString(),
        }),
        snackBarType: SnackBarType.Error,
      );
    } finally {
      // isLoading(false);
    }
  }

  Future<void> createComment({
    required int userId,
    required CommentType commentType,
    required String textContent,
    required String mediaUrl,
  }) async {
    try {
      // Don't set loading state since we're not awaiting the response
      // isLoading(true);

      // Fire and forget - don't await the response
      sl<CreateCommentUsecase>()
          .call(
            CreateCommentParams(
              postId: postId,
              commentType: commentType.name,
              textContent: textContent,
              mediaUrl: mediaUrl,
            ),
          )
          .then((response) {
            if (response.error != null) {
              AlertService.showSnackBar(
                title: LocaleKeys.errorTitle.tr,
                subtitle: LocaleKeys.liveFailedToCreateComment.tr,
                snackBarType: SnackBarType.Error,
              );
            } else {
              sl<AnalyticsService>().trackEvent(
                "addCommentPartner",
                eventProperties: {
                  "commentType": commentType.name,
                  "commentText": textContent,
                  "commentMediaUrl": mediaUrl,
                  ...post.eventProperties,
                },
              );
            }
          })
          .catchError((e) {
            Logger.logMessage('Error creating comment: ${e.toString()}');
            AlertService.showSnackBar(
              title: LocaleKeys.errorTitle.tr,
              subtitle: LocaleKeys.liveSomethingWentWrongDetail.trParams({
                'detail': e.toString(),
              }),
              snackBarType: SnackBarType.Error,
            );
          });

      // No need to refresh comments since we're adding them locally
      // fetchInitialComments();
    } catch (e) {
      Logger.logMessage('Error creating comment: ${e.toString()}');
      AlertService.showSnackBar(
        title: LocaleKeys.errorTitle.tr,
        subtitle: LocaleKeys.liveSomethingWentWrongDetail.trParams({
          'detail': e.toString(),
        }),
        snackBarType: SnackBarType.Error,
      );
    } finally {
      // isLoading(false);
    }
  }

  Future<void> createReply({
    required CommentModel comment,
    required int userId,
    required String textContent,
  }) async {
    try {
      // Initialize reactive state for this comment if not already done
      _initializeReactiveStateForComment(comment.id ?? '');

      // Don't set loading state since we're not awaiting the response
      // replyLoadingMap[commentId] = true;

      // Fire and forget - don't await the response
      sl<CreateReplyUsecase>()
          .call(
            CreateReplyParams(
              postId: postId,
              commentId: comment.id ?? '',
              textContent: textContent,
            ),
          )
          .then((response) {
            if (response.error != null) {
              AlertService.showSnackBar(
                title: LocaleKeys.errorTitle.tr,
                subtitle: LocaleKeys.liveFailedToCreateReply.tr,
                snackBarType: SnackBarType.Error,
              );
            } else {
              sl<AnalyticsService>().trackEvent(
                "addReplyPartner",
                eventProperties: {
                  "replyText": textContent,
                  ...comment.eventProperties,
                  ...post.eventProperties,
                },
              );
            }
          })
          .catchError((e) {
            Logger.logMessage('Error creating reply: ${e.toString()}');
            AlertService.showSnackBar(
              title: LocaleKeys.errorTitle.tr,
              subtitle: LocaleKeys.liveSomethingWentWrongDetail.trParams({
                'detail': e.toString(),
              }),
              snackBarType: SnackBarType.Error,
            );
          });

      // No need to refresh replies since we're adding them locally
      // fetchInitialReplies(commentId);
    } catch (e) {
      Logger.logMessage('Error creating reply: ${e.toString()}');
      AlertService.showSnackBar(
        title: LocaleKeys.errorTitle.tr,
        subtitle: LocaleKeys.liveSomethingWentWrongDetail.trParams({
          'detail': e.toString(),
        }),
        snackBarType: SnackBarType.Error,
      );
    } finally {
      // replyLoadingMap[commentId] = false;
    }
  }
}
