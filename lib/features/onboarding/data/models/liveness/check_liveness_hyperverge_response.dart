class CheckLivenessHypervergeResponse {
  final String? status;
  final int? statusCode;
  final Metadata? metadata;
  final Result? result;

  CheckLivenessHypervergeResponse({
    this.status,
    this.statusCode,
    this.metadata,
    this.result,
  });

  CheckLivenessHypervergeResponse.fromJson(Map<String, dynamic> json)
    : status = json['status'] as String?,
      statusCode = json['statusCode'] as int?,
      metadata =
          (json['metadata'] as Map<String, dynamic>?) != null
              ? Metadata.fromJson(json['metadata'] as Map<String, dynamic>)
              : null,
      result =
          (json['result'] as Map<String, dynamic>?) != null
              ? Result.fromJson(json['result'] as Map<String, dynamic>)
              : null;

  Map<String, dynamic> toJson() => {
    'status': status,
    'statusCode': statusCode,
    'metadata': metadata?.toJson(),
    'result': result?.toJson(),
  };

  /// Validates if the picture meets all safety requirements
  /// Returns true if all checks pass, false otherwise
  bool get isPictureSafe {
    return validationResult.isValid;
  }

  /// Provides detailed validation result with status and failure message
  LivenessValidationResult get validationResult {
    final details = result?.details;

    if (details == null) {
      return LivenessValidationResult(
        isValid: false,
        failureReason: 'No details available for validation',
      );
    }

    // Check live face requirement
    final liveFaceCheck = _validateCheck(
      check: details.liveFace,
      expectedValue: 'yes',
      checkName: 'Live Face',
      minConfidence: 80,
      failureReason: 'Live face not detected in the image, please click again',
    );
    if (!liveFaceCheck.isValid) return liveFaceCheck;

    // Check multiple faces requirement
    final multipleFacesCheck = _validateCheck(
      check: details.qualityChecks?.multipleFaces,
      expectedValue: 'no',
      checkName: 'Multiple Faces',
      failureReason: 'Multiple faces detected, please click again',
    );
    if (!multipleFacesCheck.isValid) return multipleFacesCheck;

    // Check eyes closed requirement
    final eyesClosedCheck = _validateCheck(
      check: details.qualityChecks?.eyesClosed,
      expectedValue: 'no',
      checkName: 'Eyes Closed',
      failureReason: 'Keep your eyes open and click again',
    );
    if (!eyesClosedCheck.isValid) return eyesClosedCheck;

    return LivenessValidationResult(isValid: true);
  }

  /// Internal method to validate individual checks
  LivenessValidationResult _validateCheck({
    required QualityChecksDetails? check,
    required String expectedValue,
    required String checkName,
    required String failureReason,
    int? minConfidence,
  }) {
    if (check == null) {
      return LivenessValidationResult(
        isValid: false,
        failureReason: '$checkName check is not available: $failureReason',
      );
    }

    if (check.value == null) {
      return LivenessValidationResult(
        isValid: false,
        failureReason: '$checkName value is missing: $failureReason',
      );
    }

    if (check.value!.toLowerCase() != expectedValue.toLowerCase()) {
      return LivenessValidationResult(
        isValid: false,
        failureReason: '$checkName check failed: $failureReason',
      );
    }

    // Check score level
    final scoreValue = check.score;
    if (scoreValue == null) {
      return LivenessValidationResult(
        isValid: false,
        failureReason: '$checkName score is missing',
      );
    }

    if (minConfidence != null) {
      if (scoreValue < minConfidence) {
        return LivenessValidationResult(
          isValid: false,
          failureReason: '$checkName score check failed: $failureReason',
        );
      }
    }

    return LivenessValidationResult(isValid: true);
  }
}

class Metadata {
  final String? requestId;
  final String? transactionId;

  Metadata({this.requestId, this.transactionId});

  Metadata.fromJson(Map<String, dynamic> json)
    : requestId = json['requestId'] as String?,
      transactionId = json['transactionId'] as String?;

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'transactionId': transactionId,
  };
}

class Result {
  final Details? details;
  final InputImageUrls? inputImageUrls;
  final String? croppedImageUrl;

  Result({this.details, this.inputImageUrls, this.croppedImageUrl});

  Result.fromJson(Map<String, dynamic> json)
    : details =
          (json['details'] as Map<String, dynamic>?) != null
              ? Details.fromJson(json['details'] as Map<String, dynamic>)
              : null,
      inputImageUrls =
          (json['inputImageUrls'] as Map<String, dynamic>?) != null
              ? InputImageUrls.fromJson(
                json['inputImageUrls'] as Map<String, dynamic>,
              )
              : null,
      croppedImageUrl = json['croppedImageUrl'] as String?;

  Map<String, dynamic> toJson() => {
    'details': details?.toJson(),
    'inputImageUrls': inputImageUrls?.toJson(),
    'croppedImageUrl': croppedImageUrl,
  };
}

class Details {
  final QualityChecksDetails? liveFace;
  final QualityChecks? qualityChecks;

  Details({this.liveFace, this.qualityChecks});

  Details.fromJson(Map<String, dynamic> json)
    : liveFace =
          (json['liveFace'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['liveFace'] as Map<String, dynamic>,
              )
              : null,
      qualityChecks =
          (json['qualityChecks'] as Map<String, dynamic>?) != null
              ? QualityChecks.fromJson(
                json['qualityChecks'] as Map<String, dynamic>,
              )
              : null;

  Map<String, dynamic> toJson() => {
    'liveFace': liveFace?.toJson(),
    'qualityChecks': qualityChecks?.toJson(),
  };
}

class QualityChecks {
  final QualityChecksDetails? multipleFaces;
  final QualityChecksDetails? eyewear;
  final QualityChecksDetails? readingGlasses;
  final QualityChecksDetails? sunglasses;
  final QualityChecksDetails? nudity;
  final QualityChecksDetails? faceOccluded;
  final QualityChecksDetails? headTurned;
  final QualityChecksDetails? bright;
  final QualityChecksDetails? dull;
  final QualityChecksDetails? blur;
  final QualityChecksDetails? eyesClosed;
  final QualityChecksDetails? nonWhiteBackground;
  final QualityChecksDetails? hat;
  final QualityChecksDetails? maskPresent;

  QualityChecks({
    this.multipleFaces,
    this.eyewear,
    this.readingGlasses,
    this.sunglasses,
    this.nudity,
    this.faceOccluded,
    this.headTurned,
    this.bright,
    this.dull,
    this.blur,
    this.eyesClosed,
    this.nonWhiteBackground,
    this.hat,
    this.maskPresent,
  });

  QualityChecks.fromJson(Map<String, dynamic> json)
    : multipleFaces =
          (json['multipleFaces'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['multipleFaces'] as Map<String, dynamic>,
              )
              : null,
      eyewear =
          (json['eyewear'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['eyewear'] as Map<String, dynamic>,
              )
              : null,
      readingGlasses =
          (json['readingGlasses'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['readingGlasses'] as Map<String, dynamic>,
              )
              : null,
      sunglasses =
          (json['sunglasses'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['sunglasses'] as Map<String, dynamic>,
              )
              : null,
      nudity =
          (json['nudity'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['nudity'] as Map<String, dynamic>,
              )
              : null,
      faceOccluded =
          (json['faceOccluded'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['faceOccluded'] as Map<String, dynamic>,
              )
              : null,
      headTurned =
          (json['headTurned'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['headTurned'] as Map<String, dynamic>,
              )
              : null,
      bright =
          (json['bright'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['bright'] as Map<String, dynamic>,
              )
              : null,
      dull =
          (json['dull'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['dull'] as Map<String, dynamic>,
              )
              : null,
      blur =
          (json['blur'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['blur'] as Map<String, dynamic>,
              )
              : null,
      eyesClosed =
          (json['eyesClosed'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['eyesClosed'] as Map<String, dynamic>,
              )
              : null,
      nonWhiteBackground =
          (json['nonWhiteBackground'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['nonWhiteBackground'] as Map<String, dynamic>,
              )
              : null,
      hat =
          (json['hat'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['hat'] as Map<String, dynamic>,
              )
              : null,
      maskPresent =
          (json['maskPresent'] as Map<String, dynamic>?) != null
              ? QualityChecksDetails.fromJson(
                json['maskPresent'] as Map<String, dynamic>,
              )
              : null;

  Map<String, dynamic> toJson() => {
    'multipleFaces': multipleFaces?.toJson(),
    'eyewear': eyewear?.toJson(),
    'readingGlasses': readingGlasses?.toJson(),
    'sunglasses': sunglasses?.toJson(),
    'nudity': nudity?.toJson(),
    'faceOccluded': faceOccluded?.toJson(),
    'headTurned': headTurned?.toJson(),
    'bright': bright?.toJson(),
    'dull': dull?.toJson(),
    'blur': blur?.toJson(),
    'eyesClosed': eyesClosed?.toJson(),
    'nonWhiteBackground': nonWhiteBackground?.toJson(),
    'hat': hat?.toJson(),
    'maskPresent': maskPresent?.toJson(),
  };
}

class QualityChecksDetails {
  final String? value;
  final int? score;
  final String? confidence;

  QualityChecksDetails({this.value, this.score, this.confidence});

  QualityChecksDetails.fromJson(Map<String, dynamic> json)
    : value = json['value'] as String?,
      score = json['score'] as int?,
      confidence = json['confidence'] as String?;

  Map<String, dynamic> toJson() => {
    'value': value,
    'score': score,
    'confidence': confidence,
  };
}

class InputImageUrls {
  final String? image;

  InputImageUrls({this.image});

  InputImageUrls.fromJson(Map<String, dynamic> json)
    : image = json['image'] as String?;

  Map<String, dynamic> toJson() => {'image': image};
}

/// Result class for liveness validation
class LivenessValidationResult {
  final bool isValid;
  final String? failureReason;

  LivenessValidationResult({required this.isValid, this.failureReason});

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
