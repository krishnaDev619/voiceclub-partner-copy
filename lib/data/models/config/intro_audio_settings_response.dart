import 'package:voiceclub_partner/core/constants/enums.dart';

class IntroAudioSettingsResponse {
  final bool? enabled;
  final String? source;
  final String? variant;
  final String? collectionStep;

  IntroAudioSettingsResponse({
    this.enabled,
    this.source,
    this.variant,
    this.collectionStep,
  });

  /// App behavior uses [collectionStep]. A null step is treated as PROBATION.
  IntroAudioCollectionStep get parsedCollectionStep =>
      collectionStep.toIntroAudioCollectionStep();

  factory IntroAudioSettingsResponse.fromJson(Map<String, dynamic> json) {
    final map =
        json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : json;
    return IntroAudioSettingsResponse(
      enabled: map['enabled'] as bool?,
      source: map['source'] as String?,
      variant: map['variant'] as String?,
      collectionStep: map['collection_step'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'source': source,
    'variant': variant,
    'collection_step': collectionStep,
  };
}
