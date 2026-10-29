import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/file_service.dart';
import 'package:voiceclub_partner/data/models/chat/send_chat_message_response.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class SendChatMessageUsecase
    implements
        UseCase<
          DataState<SendChatMessageResponseModel>,
          SendChatMessageParams
        > {
  final ChatRepository _chatRepository;

  SendChatMessageUsecase(this._chatRepository);

  @override
  Future<DataState<SendChatMessageResponseModel>> call(
    SendChatMessageParams params,
  ) async {
    String attachmentUrl = params.attachmentUrl ?? '';
    try {
      if (params.attachment != null) {
        final response = await _chatRepository.uploadChatAttachment(
          attachment: params.attachment!,
          extension: FileService.getFileExtension(params.attachment!),
        );
        if (response.data != null) {
          attachmentUrl = response.data?.url ?? '';
        } else if (response.error != null) {
          return DataFailed(response.error!);
        }
      }

      return _chatRepository.sendChatMessage(
        groupId: params.groupId,
        type: params.type,
        attachmentUrl: attachmentUrl,
        content: params.content,
        isSessionOngoing: params.isSessionOngoing,
      );
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}

class SendChatMessageParams extends Equatable {
  final int groupId;
  final String type;
  final File? attachment;
  final String? attachmentUrl;
  final String content;
  final bool isSessionOngoing;

  const SendChatMessageParams({
    required this.groupId,
    required this.type,
    this.attachment,
    this.attachmentUrl,
    required this.content,
    required this.isSessionOngoing,
  });

  @override
  List<Object> get props => [groupId, type, content, isSessionOngoing];
}
