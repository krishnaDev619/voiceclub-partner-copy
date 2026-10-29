class CheckLivenessIdtoResponse {
  final String? status;
  final CheckLivenessIdtoResult? result;
  final String? chargeble;
  final String? userConsent;

  CheckLivenessIdtoResponse({
    this.status,
    this.result,
    this.chargeble,
    this.userConsent,
  });

  CheckLivenessIdtoResponse.fromJson(Map<String, dynamic> json)
    : status = json['status'] as String?,
      result =
          (json['result'] as Map<String, dynamic>?) != null
              ? CheckLivenessIdtoResult.fromJson(
                json['result'] as Map<String, dynamic>,
              )
              : null,
      chargeble = json['chargeble'] as String?,
      userConsent = json['user_consent'] as String?;

  Map<String, dynamic> toJson() => {
    'status': status,
    'result': result?.toJson(),
    'chargeble': chargeble,
    'user_consent': userConsent,
  };

  /// Validates if the liveness check passed all requirements
  bool get isPictureSafe {
    return validationResult.isValid;
  }

  /// Provides detailed validation result with status and failure message
  LivenessIdtoValidationResult get validationResult {
    if (result == null) {
      return LivenessIdtoValidationResult(
        isValid: false,
        failureReason: 'No result available for validation',
      );
    }

    if (result!.isLive != true) {
      return LivenessIdtoValidationResult(
        isValid: false,
        failureReason:
            'Live face not detected in the image, please click again',
      );
    }

    if (result!.multipleFaceDetected == true) {
      return LivenessIdtoValidationResult(
        isValid: false,
        failureReason: 'Multiple faces detected, please click again',
      );
    }

    if (result!.eyeClosed == true) {
      return LivenessIdtoValidationResult(
        isValid: false,
        failureReason: 'Keep your eyes open and click again',
      );
    }

    if (result!.isPersonImageBlurry == true) {
      return LivenessIdtoValidationResult(
        isValid: false,
        failureReason: 'Image is blurry, please click again',
      );
    }

    if (result!.isFaceOccluded == true) {
      return LivenessIdtoValidationResult(
        isValid: false,
        failureReason: 'Face is occluded, please click again',
      );
    }

    if (result!.hasMask == true) {
      return LivenessIdtoValidationResult(
        isValid: false,
        failureReason: 'Mask detected, please remove it and click again',
      );
    }

    if (result!.isLowLightImage == true) {
      return LivenessIdtoValidationResult(
        isValid: false,
        failureReason: 'Low light detected, please move to a brighter area',
      );
    }

    return LivenessIdtoValidationResult(isValid: true);
  }
}

class CheckLivenessIdtoResult {
  final bool? isLive;
  final bool? isPersonImageBlurry;
  final num? livenessConfidence;
  final bool? personImageCorrectlyIdentified;
  final bool? eyeClosed;
  final bool? isFaceAligned;
  final bool? isLowLightImage;
  final bool? multipleFaceDetected;
  final bool? isFaceOccluded;
  final num? occlusionConfidence;
  final bool? hasMask;
  final num? maskConfidence;

  CheckLivenessIdtoResult({
    this.isLive,
    this.isPersonImageBlurry,
    this.livenessConfidence,
    this.personImageCorrectlyIdentified,
    this.eyeClosed,
    this.isFaceAligned,
    this.isLowLightImage,
    this.multipleFaceDetected,
    this.isFaceOccluded,
    this.occlusionConfidence,
    this.hasMask,
    this.maskConfidence,
  });

  CheckLivenessIdtoResult.fromJson(Map<String, dynamic> json)
    : isLive = json['is_live'] as bool?,
      isPersonImageBlurry = json['is_person_image_blurry'] as bool?,
      livenessConfidence = json['liveness_confidence'] as num?,
      personImageCorrectlyIdentified =
          json['person_image_correctly_identified'] as bool?,
      eyeClosed = json['eye_closed'] as bool?,
      isFaceAligned = json['is_face_aligned'] as bool?,
      isLowLightImage = json['is_low_light_image'] as bool?,
      multipleFaceDetected = json['multiple_face_detected'] as bool?,
      isFaceOccluded = json['is_face_occluded'] as bool?,
      occlusionConfidence = json['occlusion_confidence'] as num?,
      hasMask = json['has_mask'] as bool?,
      maskConfidence = json['mask_confidence'] as num?;

  Map<String, dynamic> toJson() => {
    'is_live': isLive,
    'is_person_image_blurry': isPersonImageBlurry,
    'liveness_confidence': livenessConfidence,
    'person_image_correctly_identified': personImageCorrectlyIdentified,
    'eye_closed': eyeClosed,
    'is_face_aligned': isFaceAligned,
    'is_low_light_image': isLowLightImage,
    'multiple_face_detected': multipleFaceDetected,
    'is_face_occluded': isFaceOccluded,
    'occlusion_confidence': occlusionConfidence,
    'has_mask': hasMask,
    'mask_confidence': maskConfidence,
  };
}

/// Result class for IDTO liveness validation
class LivenessIdtoValidationResult {
  final bool isValid;
  final String? failureReason;

  LivenessIdtoValidationResult({required this.isValid, this.failureReason});

  /// Returns a user-friendly error message
  String get errorMessage {
    return failureReason ?? 'Validation failed';
  }

  @override
  String toString() {
    return isValid
        ? 'Validation passed'
        : 'Validation failed: ${failureReason ?? "Unknown reason"}';
  }
}
