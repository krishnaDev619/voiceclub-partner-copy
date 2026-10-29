import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/social/create_post_response.dart';
import 'package:voiceclub_partner/data/models/social/fetch_all_reactions_response.dart';
import 'package:voiceclub_partner/data/models/social/get_all_reactions.dart';
import 'package:voiceclub_partner/data/models/social/get_pending_post_status_response.dart';
import 'package:voiceclub_partner/data/models/social/get_post_by_id_response.dart';
import 'package:voiceclub_partner/data/models/social/list_comments_response.dart';
import 'package:voiceclub_partner/data/models/social/list_posts_response.dart';
import 'package:voiceclub_partner/data/models/social/list_replies_response.dart';

part 'social_api_service.g.dart';

@RestApi()
abstract class SocialApiService {
  factory SocialApiService(Dio dio) = _SocialApiService;

  @POST(APIConstants.createPostRoute)
  Future<HttpResponse<CreatePostResponseModel>> createPost({
    @Field('post_type') required String postType,
    @Field('text_content') required String textContent,
    @Field('media_url') required String mediaUrl,
    @Field('post_color') required String postColor,
    @Field('font_style') required String fontStyle,
    @Field('text_overlay') required String textOverlay,
  });

  @GET(APIConstants.getPostByIdRoute)
  Future<HttpResponse<GetPostByIdResponseModel>> getPostById({
    @Path('postId') required String postId,
  });

  @GET(APIConstants.listPostsRoute)
  Future<HttpResponse<ListPostsResponseModel>> listPosts({
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @GET(APIConstants.listMyPostsRoute)
  Future<HttpResponse<ListPostsResponseModel>> listMyPosts({
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @GET(APIConstants.listMyUserPostsRoute)
  Future<HttpResponse<ListPostsResponseModel>> listMyUserPosts({
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @POST(APIConstants.createCommentRoute)
  Future<HttpResponse> createComment({
    @Field('post_id') required String postId,
    @Field('comment_type') required String commentType,
    @Field('text_content') required String textContent,
    @Field('media_url') required String mediaUrl,
  });

  @GET(APIConstants.listCommentsRoute)
  Future<HttpResponse<ListCommentsResponseModel>> listComments({
    @Path('postId') required String postId,
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @POST(APIConstants.createReplyRoute)
  Future<HttpResponse> createReply({
    @Field('post_id') required String postId,
    @Field('comment_id') required String commentId,
    @Field('text_content') required String textContent,
  });

  @GET(APIConstants.listRepliesRoute)
  Future<HttpResponse<ListRepliesResponseModel>> listReplies({
    @Path('postId') required String postId,
    @Path('commentId') required String commentId,
    @Query('page') required int page,
    @Query('page_size') required int pageSize,
  });

  @POST(APIConstants.likePostRoute)
  Future<HttpResponse> likePost({@Path('postId') required String postId});

  @DELETE(APIConstants.unlikePostRoute)
  Future<HttpResponse> unlikePost({@Path('postId') required String postId});

  @POST(APIConstants.reactPostRoute)
  Future<HttpResponse> reactPost({
    @Path('postId') required String postId,
    @Path('reactionType') required String reactionType,
  });

  @DELETE(APIConstants.unReactPostRoute)
  Future<HttpResponse> unReactPost({@Path('postId') required String postId});

  @POST(APIConstants.likeCommentRoute)
  Future<HttpResponse> likeComment({
    @Path('postId') required String postId,
    @Path('commentId') required String commentId,
  });

  @DELETE(APIConstants.unlikeCommentRoute)
  Future<HttpResponse> unlikeComment({
    @Path('postId') required String postId,
    @Path('commentId') required String commentId,
  });

  @POST(APIConstants.likeReplyRoute)
  Future<HttpResponse> likeReply({
    @Path('postId') required String postId,
    @Path('commentId') required String commentId,
    @Path('replyId') required String replyId,
  });

  @DELETE(APIConstants.unlikeReplyRoute)
  Future<HttpResponse> unlikeReply({
    @Path('postId') required String postId,
    @Path('commentId') required String commentId,
    @Path('replyId') required String replyId,
  });

  @GET(APIConstants.getPostReactionsRoute)
  Future<HttpResponse<GetAllPostReactionsResponseModel>> getPostReactions({
    @Path('postId') required String postId,
  });

  @GET(APIConstants.getPendingPostStatusRoute)
  Future<HttpResponse<GetPendingPostStatusResponseModel>> getPendingPostStatus({
    @Path('postId') required String postId,
  });

  @DELETE(APIConstants.deleteCommentRoute)
  Future<HttpResponse> deleteComment({
    @Path('postId') required String postId,
    @Path('commentId') required String commentId,
  });

  @GET(APIConstants.getAllReactionsRoute)
  Future<HttpResponse<GetAllReactionsResponse>> getAllReactions({
    @Path('postId') required String postId,
    @Query('reaction') required String reaction,
  });
}
