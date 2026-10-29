import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/data/models/open_ai/analyze_audio_response.dart';

abstract class OpenAIRepository {
  Future<DataState<AnalyzeAudioResponseModel>> analyzeAudio({
    required String base64Audio,
    required String fileExtension,
    String? prompt,
  });
}
