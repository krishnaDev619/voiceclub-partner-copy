import 'dart:convert';

import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

class AnalyzeAudioResponseModel {
  final List<Choices>? choices;
  final int? created;
  final String? id;
  final String? model;
  final String? object;
  final List<PromptFilterResults>? promptFilterResults;
  final String? systemFingerprint;
  final Usage? usage;

  AnalyzeAudioResponseModel({
    this.choices,
    this.created,
    this.id,
    this.model,
    this.object,
    this.promptFilterResults,
    this.systemFingerprint,
    this.usage,
  });

  AnalyzeAudioResponseModel.fromJson(Map<String, dynamic> json)
    : choices =
          (json['choices'] as List?)
              ?.map((dynamic e) => Choices.fromJson(e as Map<String, dynamic>))
              .toList(),
      created = json['created'] as int?,
      id = json['id'] as String?,
      model = json['model'] as String?,
      object = json['object'] as String?,
      promptFilterResults =
          (json['prompt_filter_results'] as List?)
              ?.map(
                (dynamic e) =>
                    PromptFilterResults.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      systemFingerprint = json['system_fingerprint'] as String?,
      usage =
          (json['usage'] as Map<String, dynamic>?) != null
              ? Usage.fromJson(json['usage'] as Map<String, dynamic>)
              : null;

  Map<String, dynamic> toJson() => {
    'choices': choices?.map((e) => e.toJson()).toList(),
    'created': created,
    'id': id,
    'model': model,
    'object': object,
    'prompt_filter_results':
        promptFilterResults?.map((e) => e.toJson()).toList(),
    'system_fingerprint': systemFingerprint,
    'usage': usage?.toJson(),
  };
}

class Choices {
  final ContentFilterResults? contentFilterResults;
  final String? finishReason;
  final int? index;
  final Message? message;

  Choices({
    this.contentFilterResults,
    this.finishReason,
    this.index,
    this.message,
  });

  Choices.fromJson(Map<String, dynamic> json)
    : contentFilterResults =
          (json['content_filter_results'] as Map<String, dynamic>?) != null
              ? ContentFilterResults.fromJson(
                json['content_filter_results'] as Map<String, dynamic>,
              )
              : null,
      finishReason = json['finish_reason'] as String?,
      index = json['index'] as int?,
      message =
          (json['message'] as Map<String, dynamic>?) != null
              ? Message.fromJson(json['message'] as Map<String, dynamic>)
              : null;

  Map<String, dynamic> toJson() => {
    'content_filter_results': contentFilterResults?.toJson(),
    'finish_reason': finishReason,
    'index': index,
    'message': message?.toJson(),
  };
}

class ContentFilterResults {
  final Hate? hate;
  final SelfHarm? selfHarm;
  final Sexual? sexual;
  final Violence? violence;

  ContentFilterResults({this.hate, this.selfHarm, this.sexual, this.violence});

  ContentFilterResults.fromJson(Map<String, dynamic> json)
    : hate =
          (json['hate'] as Map<String, dynamic>?) != null
              ? Hate.fromJson(json['hate'] as Map<String, dynamic>)
              : null,
      selfHarm =
          (json['self_harm'] as Map<String, dynamic>?) != null
              ? SelfHarm.fromJson(json['self_harm'] as Map<String, dynamic>)
              : null,
      sexual =
          (json['sexual'] as Map<String, dynamic>?) != null
              ? Sexual.fromJson(json['sexual'] as Map<String, dynamic>)
              : null,
      violence =
          (json['violence'] as Map<String, dynamic>?) != null
              ? Violence.fromJson(json['violence'] as Map<String, dynamic>)
              : null;

  Map<String, dynamic> toJson() => {
    'hate': hate?.toJson(),
    'self_harm': selfHarm?.toJson(),
    'sexual': sexual?.toJson(),
    'violence': violence?.toJson(),
  };
}

class Hate {
  final bool? filtered;
  final String? severity;

  Hate({this.filtered, this.severity});

  Hate.fromJson(Map<String, dynamic> json)
    : filtered = json['filtered'] as bool?,
      severity = json['severity'] as String?;

  Map<String, dynamic> toJson() => {'filtered': filtered, 'severity': severity};
}

class SelfHarm {
  final bool? filtered;
  final String? severity;

  SelfHarm({this.filtered, this.severity});

  SelfHarm.fromJson(Map<String, dynamic> json)
    : filtered = json['filtered'] as bool?,
      severity = json['severity'] as String?;

  Map<String, dynamic> toJson() => {'filtered': filtered, 'severity': severity};
}

class Sexual {
  final bool? filtered;
  final String? severity;

  Sexual({this.filtered, this.severity});

  Sexual.fromJson(Map<String, dynamic> json)
    : filtered = json['filtered'] as bool?,
      severity = json['severity'] as String?;

  Map<String, dynamic> toJson() => {'filtered': filtered, 'severity': severity};
}

class Violence {
  final bool? filtered;
  final String? severity;

  Violence({this.filtered, this.severity});

  Violence.fromJson(Map<String, dynamic> json)
    : filtered = json['filtered'] as bool?,
      severity = json['severity'] as String?;

  Map<String, dynamic> toJson() => {'filtered': filtered, 'severity': severity};
}

class Message {
  final Audio? audio;
  final String? role;

  Message({this.audio, this.role});

  Message.fromJson(Map<String, dynamic> json)
    : audio =
          (json['audio'] as Map<String, dynamic>?) != null
              ? Audio.fromJson(json['audio'] as Map<String, dynamic>)
              : null,
      role = json['role'] as String?;

  Map<String, dynamic> toJson() => {'audio': audio?.toJson(), 'role': role};
}

class Audio {
  final String? data;
  final int? expiresAt;
  final String? id;
  final TranscriptResponse? transcript;

  Audio({this.data, this.expiresAt, this.id, this.transcript});

  Audio.fromJson(Map<String, dynamic> json)
    : data = json['data'] as String?,
      expiresAt = json['expires_at'] as int?,
      id = json['id'] as String?,
      transcript = parseTranscript(json['transcript']);

  Map<String, dynamic> toJson() => {
    'data': data,
    'expires_at': expiresAt,
    'id': id,
    'transcript': transcript?.toJson(),
  };

  static TranscriptResponse? parseTranscript(dynamic transcript) {
    if (transcript == null) return null;
    try {
      if (transcript is Map<String, dynamic>) {
        // Already a map, just parse
        return TranscriptResponse.fromJson(transcript);
      } else if (transcript is String) {
        // Might be a JSON string, try to decode
        final decoded = jsonDecode(transcript);
        if (decoded is Map<String, dynamic>) {
          return TranscriptResponse.fromJson(decoded);
        } else {
          Logger.logMessage('Decoded transcript is not a Map: $decoded');
          return null;
        }
      } else {
        Logger.logMessage(
          'Unexpected transcript type: ${transcript.runtimeType}',
        );
        return null;
      }
    } catch (e) {
      Logger.logMessage('Error parsing transcript: $e, value: $transcript');
      return null;
    }
  }
}

class TranscriptResponse {
  final IntroAudioDecision? decision;
  final String? feedback;
  final String? reason;

  TranscriptResponse({this.decision, this.feedback, this.reason});

  factory TranscriptResponse.fromJson(dynamic json) {
    try {
      return TranscriptResponse(
        decision: (json['decision'] as String?)?.toIntroAudioDecision(),
        feedback: json['feedback'] as String?,
        reason: json['reason'] as String?,
      );
    } catch (e) {
      Logger.logMessage('Error parsing TranscriptResponse: $e');
      return TranscriptResponse();
    }
  }

  Map<String, dynamic> toJson() => {
    'decision': decision?.name,
    'feedback': feedback,
    'reason': reason,
  };
}

class PromptFilterResults {
  final int? promptIndex;
  final ContentFilterResults? contentFilterResults;

  PromptFilterResults({this.promptIndex, this.contentFilterResults});

  PromptFilterResults.fromJson(Map<String, dynamic> json)
    : promptIndex = json['prompt_index'] as int?,
      contentFilterResults =
          (json['content_filter_results'] as Map<String, dynamic>?) != null
              ? ContentFilterResults.fromJson(
                json['content_filter_results'] as Map<String, dynamic>,
              )
              : null;

  Map<String, dynamic> toJson() => {
    'prompt_index': promptIndex,
    'content_filter_results': contentFilterResults?.toJson(),
  };
}

class Usage {
  final int? completionTokens;
  final CompletionTokensDetails? completionTokensDetails;
  final int? promptTokens;
  final PromptTokensDetails? promptTokensDetails;
  final int? totalTokens;

  Usage({
    this.completionTokens,
    this.completionTokensDetails,
    this.promptTokens,
    this.promptTokensDetails,
    this.totalTokens,
  });

  Usage.fromJson(Map<String, dynamic> json)
    : completionTokens = json['completion_tokens'] as int?,
      completionTokensDetails =
          (json['completion_tokens_details'] as Map<String, dynamic>?) != null
              ? CompletionTokensDetails.fromJson(
                json['completion_tokens_details'] as Map<String, dynamic>,
              )
              : null,
      promptTokens = json['prompt_tokens'] as int?,
      promptTokensDetails =
          (json['prompt_tokens_details'] as Map<String, dynamic>?) != null
              ? PromptTokensDetails.fromJson(
                json['prompt_tokens_details'] as Map<String, dynamic>,
              )
              : null,
      totalTokens = json['total_tokens'] as int?;

  Map<String, dynamic> toJson() => {
    'completion_tokens': completionTokens,
    'completion_tokens_details': completionTokensDetails?.toJson(),
    'prompt_tokens': promptTokens,
    'prompt_tokens_details': promptTokensDetails?.toJson(),
    'total_tokens': totalTokens,
  };
}

class CompletionTokensDetails {
  final int? acceptedPredictionTokens;
  final int? audioTokens;
  final int? reasoningTokens;
  final int? rejectedPredictionTokens;
  final int? textTokens;

  CompletionTokensDetails({
    this.acceptedPredictionTokens,
    this.audioTokens,
    this.reasoningTokens,
    this.rejectedPredictionTokens,
    this.textTokens,
  });

  CompletionTokensDetails.fromJson(Map<String, dynamic> json)
    : acceptedPredictionTokens = json['accepted_prediction_tokens'] as int?,
      audioTokens = json['audio_tokens'] as int?,
      reasoningTokens = json['reasoning_tokens'] as int?,
      rejectedPredictionTokens = json['rejected_prediction_tokens'] as int?,
      textTokens = json['text_tokens'] as int?;

  Map<String, dynamic> toJson() => {
    'accepted_prediction_tokens': acceptedPredictionTokens,
    'audio_tokens': audioTokens,
    'reasoning_tokens': reasoningTokens,
    'rejected_prediction_tokens': rejectedPredictionTokens,
    'text_tokens': textTokens,
  };
}

class PromptTokensDetails {
  final int? audioTokens;
  final int? cachedTokens;
  final int? imageTokens;
  final int? textTokens;

  PromptTokensDetails({
    this.audioTokens,
    this.cachedTokens,
    this.imageTokens,
    this.textTokens,
  });

  PromptTokensDetails.fromJson(Map<String, dynamic> json)
    : audioTokens = json['audio_tokens'] as int?,
      cachedTokens = json['cached_tokens'] as int?,
      imageTokens = json['image_tokens'] as int?,
      textTokens = json['text_tokens'] as int?;

  Map<String, dynamic> toJson() => {
    'audio_tokens': audioTokens,
    'cached_tokens': cachedTokens,
    'image_tokens': imageTokens,
    'text_tokens': textTokens,
  };
}
