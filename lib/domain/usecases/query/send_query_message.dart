import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/domain/repository/query_repository.dart';

class SendQueryMessageUseCase
    implements UseCase<DataState<void>, SendQueryMessageParams> {
  final QueryRepository _queryRepository;

  SendQueryMessageUseCase(this._queryRepository);

  @override
  Future<DataState<void>> call(SendQueryMessageParams params) async {
    final response = await _queryRepository.sendQueryBotMessage(
      sessionId: params.sessionId,
      messageType: params.messageType.name,
      content: params.content,
      attachment: params.attachment,
      actionOptionType: params.actionOptionType,
      actionValue: params.actionValue,
      externalId: params.externalId,
    );
    return response;
  }
}

class SendQueryMessageParams extends Equatable {
  final String sessionId;
  final QueryMessageType messageType;
  final String? content;
  final File? attachment;
  final String? actionOptionType;
  final String? actionValue;
  final int? externalId;

  const SendQueryMessageParams({
    required this.sessionId,
    required this.messageType,
    this.content,
    this.attachment,
    this.actionOptionType,
    this.actionValue,
    this.externalId,
  });

  @override
  List<Object> get props => [sessionId];
}
