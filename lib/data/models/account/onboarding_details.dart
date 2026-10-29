class OnboardingDetailsResponseModel {
  final int? id;
  final String? name;
  final String? maritalStatus;
  final String? phone;
  final String? countryCode;
  final bool? hasPan;
  final bool? hasAadhar;
  final bool? otpVerified;
  final String? profileStatus;
  final bool? hasWatchedTutorial;
  final bool? isLegalDocumentSigned;
  final String? firstLanguage;
  final String? secondLanguage;
  final String? appLanguage;
  final String? imagePath;
  final String? signedLegalDocumentPath;
  final String? sampleAudioPath;
  final bool? kycCompleted;

  OnboardingDetailsResponseModel({
    this.id,
    this.name,
    this.maritalStatus,
    this.phone,
    this.countryCode,
    this.hasPan,
    this.hasAadhar,
    this.otpVerified,
    this.profileStatus,
    this.hasWatchedTutorial,
    this.isLegalDocumentSigned,
    this.firstLanguage,
    this.secondLanguage,
    this.appLanguage,
    this.imagePath,
    this.signedLegalDocumentPath,
    this.sampleAudioPath,
    this.kycCompleted,
  });

  OnboardingDetailsResponseModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      name = json['name'] as String?,
      maritalStatus = json['marital_status'] as String?,
      phone = json['phone'] as String?,
      countryCode = json['country_code'] as String?,
      hasPan = json['has_pan'] as bool?,
      hasAadhar = json['has_aadhar'] as bool?,
      otpVerified = json['otp_verified'] as bool?,
      profileStatus = json['profile_status'] as String?,
      hasWatchedTutorial = json['HasWatchedTutorial'] as bool?,
      isLegalDocumentSigned = json['IsLegalDocumentSigned'] as bool?,
      firstLanguage = json['first_language'] as String?,
      secondLanguage = json['second_language'] as String?,
      appLanguage = json['app_language'] as String?,
      imagePath = json['image_path'] as String?,
      signedLegalDocumentPath = json['signed_legal_document_path'] as String?,
      sampleAudioPath = json['sample_audio_path'] as String?,
      kycCompleted = json['kyc_completed'] as bool?;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'marital_status': maritalStatus,
    'phone': phone,
    'country_code': countryCode,
    'has_pan': hasPan,
    'has_aadhar': hasAadhar,
    'otp_verified': otpVerified,
    'profile_status': profileStatus,
    'HasWatchedTutorial': hasWatchedTutorial,
    'IsLegalDocumentSigned': isLegalDocumentSigned,
    'first_language': firstLanguage,
    'second_language': secondLanguage,
    'app_language': appLanguage,
    'image_path': imagePath,
    'signed_legal_document_path': signedLegalDocumentPath,
    'sample_audio_path': sampleAudioPath,
    'kyc_completed': kycCompleted,
  };
}
