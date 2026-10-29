import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/social/social_api_service.dart';
import 'package:voiceclub_partner/data/models/social/create_post_response.dart';
import 'package:voiceclub_partner/data/models/social/fetch_all_reactions_response.dart';
import 'package:voiceclub_partner/data/models/social/get_all_reactions.dart';
import 'package:voiceclub_partner/data/models/social/get_pending_post_status_response.dart';
import 'package:voiceclub_partner/data/models/social/get_post_by_id_response.dart';
import 'package:voiceclub_partner/data/models/social/list_comments_response.dart';
import 'package:voiceclub_partner/data/models/social/list_posts_response.dart';
import 'package:voiceclub_partner/data/models/social/list_replies_response.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SocialApiService _socialApiService;

  SocialRepositoryImpl(this._socialApiService);

  @override
  Future<DataState<CreatePostResponseModel>> createPost({
    required String postType,
    required String textContent,
    required String mediaUrl,
    required String postColor,
    required String fontStyle,
    required String textOverlay,
  }) async {
    try {
      final response = await _socialApiService.createPost(
        postType: postType,
        textContent: textContent,
        mediaUrl: mediaUrl,
        postColor: postColor,
        fontStyle: fontStyle,
        textOverlay: textOverlay,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetPostByIdResponseModel>> getPostById({
    required String postId,
  }) async {
    try {
      final response = await _socialApiService.getPostById(postId: postId);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ListPostsResponseModel>> listPosts({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _socialApiService.listPosts(
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ListPostsResponseModel>> listMyPosts({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _socialApiService.listMyPosts(
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ListPostsResponseModel>> listMyUserPosts({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _socialApiService.listMyUserPosts(
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> createComment({
    required String postId,
    required String commentType,
    required String textContent,
    required String mediaUrl,
  }) async {
    try {
      final response = await _socialApiService.createComment(
        postId: postId,
        commentType: commentType,
        textContent: textContent,
        mediaUrl: mediaUrl,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ListCommentsResponseModel>> listComments({
    required String postId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _socialApiService.listComments(
        postId: postId,
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> createReply({
    required String postId,
    required String commentId,
    required String textContent,
  }) async {
    try {
      final response = await _socialApiService.createReply(
        postId: postId,
        commentId: commentId,
        textContent: textContent,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<ListRepliesResponseModel>> listReplies({
    required String postId,
    required String commentId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _socialApiService.listReplies(
        postId: postId,
        commentId: commentId,
        page: page,
        pageSize: pageSize,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> likePost({required String postId}) async {
    try {
      final response = await _socialApiService.likePost(postId: postId);

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> unlikePost({required String postId}) async {
    try {
      final response = await _socialApiService.unlikePost(postId: postId);

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> reactPost({
    required String postId,
    required String reactionType,
  }) async {
    try {
      final response = await _socialApiService.reactPost(
        postId: postId,
        reactionType: reactionType,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> unReactPost({required String postId}) async {
    try {
      final response = await _socialApiService.unReactPost(postId: postId);

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> likeComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final response = await _socialApiService.likeComment(
        postId: postId,
        commentId: commentId,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> unlikeComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final response = await _socialApiService.unlikeComment(
        postId: postId,
        commentId: commentId,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> likeReply({
    required String postId,
    required String commentId,
    required String replyId,
  }) async {
    try {
      final response = await _socialApiService.likeReply(
        postId: postId,
        commentId: commentId,
        replyId: replyId,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> unlikeReply({
    required String postId,
    required String commentId,
    required String replyId,
  }) async {
    try {
      final response = await _socialApiService.unlikeReply(
        postId: postId,
        commentId: commentId,
        replyId: replyId,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetAllPostReactionsResponseModel>> getPostReactions({
    required String postId,
  }) async {
    try {
      final response = await _socialApiService.getPostReactions(postId: postId);

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetPendingPostStatusResponseModel>> getPendingPostStatus({
    required String postId,
  }) async {
    try {
      final response = await _socialApiService.getPendingPostStatus(
        postId: postId,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<void>> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      final response = await _socialApiService.deleteComment(
        postId: postId,
        commentId: commentId,
      );

      if (response.response.statusCode == 200) {
        return const DataSuccess(null);
      } else {
        return DataFailed(
          DioException(
            error: response.response.statusCode,
            message: response.response.statusMessage,
            response: response.response,
            requestOptions: response.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<GetAllReactionsResponse>> getAllReactions({
    required String postId,
    required String reaction,
  }) async {
    try {
      final response = await _socialApiService.getAllReactions(
        postId: postId,
        reaction: reaction,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
