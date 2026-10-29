import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/open_ai/analyze_audio_response.dart';
import 'package:voiceclub_partner/domain/repository/openai_repository.dart';

class AnalyzeAudioUseCase
    implements
        UseCase<DataState<AnalyzeAudioResponseModel>, AnalyzeAudioParams> {
  final OpenAIRepository _openAIRepository;

  AnalyzeAudioUseCase(this._openAIRepository);

  @override
  Future<DataState<AnalyzeAudioResponseModel>> call(
    AnalyzeAudioParams params,
  ) async {
    final audioBytes = await params.audioFile.readAsBytes();
    final base64Audio = await compute(base64Encode, audioBytes);

    // Extract file extension from the audio file path
    final filePath = params.audioFile.path.toLowerCase();
    String fileExtension = "mp3"; // default fallback
    if (filePath.endsWith('.m4a')) {
      fileExtension = "m4a";
    } else if (filePath.endsWith('.wav')) {
      fileExtension = "wav";
    } else if (filePath.endsWith('.mp3')) {
      fileExtension = "mp3";
    } else if (filePath.endsWith('.webm')) {
      fileExtension = "webm";
    }

    return _openAIRepository.analyzeAudio(
      base64Audio: base64Audio,
      fileExtension: fileExtension,
      prompt: params.prompt,
    );
  }
}

class AnalyzeAudioParams {
  final File audioFile;
  final String? prompt;

  const AnalyzeAudioParams({required this.audioFile, this.prompt});
}
