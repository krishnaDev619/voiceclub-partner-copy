import 'dart:io';

import 'package:dio/dio.dart' hide Headers;
import 'package:retrofit/retrofit.dart';
import 'package:voiceclub_partner/core/constants/api_constants.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/data/models/stories/get_my_story_response.dart';

part 'stories_api_service.g.dart';

@RestApi()
abstract class StoriesApiService {
  factory StoriesApiService(Dio dio) = _StoriesApiService;

  @POST(APIConstants.uploadStoryAudioFileRoute)
  @Headers({'Content-Type': 'multipart/form-data'})
  @MultiPart()
  Future<HttpResponse<FileResponseModel>> uploadStoryAudioFile(
    @Part(name: 'recording') File recordingFile,
  );

  @POST(APIConstants.uploadOtherFileTypesRoute)
  @Headers({'Content-Type': 'multipart/form-data'})
  @MultiPart()
  Future<HttpResponse<FileResponseModel>> uploadOtherFileTypes({
    @Part(name: 'file') required File file,
    @Path('extension') required String extension,
  });

  @POST(APIConstants.uploadStoryRoute)
  Future<HttpResponse> uploadStory(
    @Field('color') String color,
    @Field('media_url') String mediaUrl,
    @Field('media_type') String mediaType,
  );

  @GET(APIConstants.getMyStoryRoute)
  Future<HttpResponse<GetMyStoryResponseModel>> getMyStory();

  @DELETE(APIConstants.deleteStoryRoute)
  Future<HttpResponse> deleteStory(@Path('storyId') int storyId);
}
