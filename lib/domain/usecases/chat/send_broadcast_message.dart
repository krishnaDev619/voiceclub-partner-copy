import 'dart:io';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/file_service.dart';
import 'package:voiceclub_partner/domain/repository/chat_repository.dart';

class SendBroadcastMessageUsecase
    implements UseCase<DataState<String?>, SendBroadcastMessageParams> {
  final ChatRepository _chatRepository;

  SendBroadcastMessageUsecase(this._chatRepository);

  @override
  Future<DataState<String?>> call(SendBroadcastMessageParams params) async {
    try {
      String? attachmentUrl;
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
      return _chatRepository.sendBroadcastMessage(
        groupIds: params.groupIds,
        messageType: params.messageType.toChatTypeString(),
        message: params.message,
        attachmentUrl: attachmentUrl ?? '',
        type: SendBroadcastType.SELECTED.name,
      );
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}

class SendBroadcastMessageParams extends Equatable {
  final List<int> groupIds;
  final String message;
  final File? attachment;
  final ChatType messageType;

  const SendBroadcastMessageParams({
    required this.groupIds,
    required this.message,
    required this.messageType,
    this.attachment,
  });

  @override
  List<Object> get props => [groupIds, messageType, message];
}
