import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/file_service.dart';
import 'package:voiceclub_partner/data/models/social/create_post_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';
import 'package:voiceclub_partner/domain/repository/social_repository.dart';

class CreatePostUsecase
    implements UseCase<DataState<CreatePostResponseModel>, CreatePostParams> {
  final SocialRepository _socialRepository;
  final ChatRepository _chatRepository;

  CreatePostUsecase(this._socialRepository, this._chatRepository);

  @override
  Future<DataState<CreatePostResponseModel>> call(
    CreatePostParams params,
  ) async {
    String mediaUrl = params.mediaUrl;

    try {
      if (params.attachment != null) {
        final response = await _chatRepository.uploadChatAttachment(
          attachment: params.attachment!,
          extension: FileService.getFileExtension(params.attachment!),
        );
        if (response.data != null) {
          mediaUrl = response.data?.url ?? '';
        } else if (response.error != null) {
          return DataFailed(response.error!);
        }
      }

      return _socialRepository.createPost(
        postType: params.postType.name,
        textContent: params.textContent,
        mediaUrl: mediaUrl,
        postColor: params.postColor,
        fontStyle: params.fontStyle,
        textOverlay: params.textOverlay,
      );
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}

class CreatePostParams extends Equatable {
  final PostMediaType postType;
  final String textContent;
  final String mediaUrl;
  final String postColor;
  final String fontStyle;
  final String textOverlay;
  final File? attachment;

  const CreatePostParams({
    required this.postType,
    required this.textContent,
    required this.mediaUrl,
    required this.postColor,
    required this.fontStyle,
    required this.textOverlay,
    this.attachment,
  });

  @override
  List<Object?> get props => [
    postType,
    textContent,
    mediaUrl,
    postColor,
    fontStyle,
    textOverlay,
  ];
}
