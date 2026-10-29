import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/social/create_post_response.dart';
import 'package:voiceclub_partner/data/models/social/fetch_all_reactions_response.dart';
import 'package:voiceclub_partner/data/models/social/get_all_reactions.dart';
import 'package:voiceclub_partner/data/models/social/get_pending_post_status_response.dart';
import 'package:voiceclub_partner/data/models/social/get_post_by_id_response.dart';
import 'package:voiceclub_partner/data/models/social/list_comments_response.dart';
import 'package:voiceclub_partner/data/models/social/list_posts_response.dart';
import 'package:voiceclub_partner/data/models/social/list_replies_response.dart';

abstract class SocialRepository {
  Future<DataState<CreatePostResponseModel>> createPost({
    required String postType,
    required String textContent,
    required String mediaUrl,
    required String postColor,
    required String fontStyle,
    required String textOverlay,
  });

  Future<DataState<GetPostByIdResponseModel>> getPostById({
    required String postId,
  });

  Future<DataState<ListPostsResponseModel>> listPosts({
    required int page,
    required int pageSize,
  });

  Future<DataState<ListPostsResponseModel>> listMyPosts({
    required int page,
    required int pageSize,
  });

  Future<DataState<ListPostsResponseModel>> listMyUserPosts({
    required int page,
    required int pageSize,
  });

  Future<DataState<void>> createComment({
    required String postId,
    required String commentType,
    required String textContent,
    required String mediaUrl,
  });

  Future<DataState<ListCommentsResponseModel>> listComments({
    required String postId,
    required int page,
    required int pageSize,
  });

  Future<DataState<void>> createReply({
    required String postId,
    required String commentId,
    required String textContent,
  });

  Future<DataState<ListRepliesResponseModel>> listReplies({
    required String postId,
    required String commentId,
    required int page,
    required int pageSize,
  });

  Future<DataState<void>> likePost({required String postId});

  Future<DataState<void>> unlikePost({required String postId});

  Future<DataState<void>> reactPost({
    required String postId,
    required String reactionType,
  });

  Future<DataState<void>> unReactPost({required String postId});

  Future<DataState<void>> likeComment({
    required String postId,
    required String commentId,
  });

  Future<DataState<void>> unlikeComment({
    required String postId,
    required String commentId,
  });

  Future<DataState<void>> likeReply({
    required String postId,
    required String commentId,
    required String replyId,
  });

  Future<DataState<void>> unlikeReply({
    required String postId,
    required String commentId,
    required String replyId,
  });

  Future<DataState<GetAllPostReactionsResponseModel>> getPostReactions({
    required String postId,
  });

  Future<DataState<GetPendingPostStatusResponseModel>> getPendingPostStatus({
    required String postId,
  });

  Future<DataState<void>> deleteComment({
    required String postId,
    required String commentId,
  });

  Future<DataState<GetAllReactionsResponse>> getAllReactions({
    required String postId,
    required String reaction,
  });
}
