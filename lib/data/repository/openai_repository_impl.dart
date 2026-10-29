import 'package:dio/dio.dart';
import 'package:voiceclub_partner/core/constants/open_ai_constants.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/resources/http_response_handler.dart';
import 'package:voiceclub_partner/data/data_sources/remote/open_ai/openai_api_service.dart';
import 'package:voiceclub_partner/data/models/open_ai/analyze_audio_response.dart';
import 'package:voiceclub_partner/domain/repository/openai_repository.dart';

class OpenAIRepositoryImpl implements OpenAIRepository {
  final OpenAIApiService _openAIApiService;

  OpenAIRepositoryImpl(this._openAIApiService);

  @override
  Future<DataState<AnalyzeAudioResponseModel>> analyzeAudio({
    required String base64Audio,
    required String fileExtension,
    String? prompt,
  }) async {
    try {
      final body = {
        "model": OpenAIConstants.model,
        "modalities": ["text", "audio"],
        "audio": {"voice": "alloy", "format": fileExtension},
        "messages": [
          {
            "role": "user",
            "content": [
              if (prompt != null) {"type": "text", "text": prompt},
              {
                "type": "input_audio",
                "input_audio": {"data": base64Audio, "format": fileExtension},
              },
            ],
          },
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      };

      final response = await _openAIApiService.analyzeAudio(
        apiVersion: OpenAIConstants.apiVersion,
        body: body,
      );

      return toDataState(response);
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
