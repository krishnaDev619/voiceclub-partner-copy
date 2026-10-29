import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/file/upload_file_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class UploadChatAttachmentUseCase
    implements
        UseCase<DataState<FileResponseModel>, UploadChatAttachmentParams> {
  final ChatRepository chatRepository;

  UploadChatAttachmentUseCase(this.chatRepository);

  @override
  Future<DataState<FileResponseModel>> call(
    UploadChatAttachmentParams params,
  ) async {
    return chatRepository.uploadChatAttachment(
      attachment: params.attachment,
      extension: params.extension,
    );
  }
}

class UploadChatAttachmentParams extends Equatable {
  final File attachment;
  final String extension;

  const UploadChatAttachmentParams({
    required this.attachment,
    required this.extension,
  });

  @override
  List<Object?> get props => [attachment, extension];
}
