import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';

class ProfileResponseModel {
  final int? id;
  final String? name;
  final String? maritalStatus;
  final String? phone;
  final String? countryCode;
  final bool? hasPan;
  final bool? hasAadhar;
  final bool? otpVerified;
  final ProfileStatus? profileStatus;
  final bool? hasWatchedTutorial;
  final bool? isLegalDocumentSigned;
  final String? firstLanguage;
  final String? secondLanguage;
  final String? imagePath;
  final String? religion;
  final String? signedLegalDocumentPath;
  final String? city;
  final String? state;
  final bool? kycCompleted;

  ProfileResponseModel({
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
    this.imagePath,
    this.religion,
    this.signedLegalDocumentPath,
    this.city,
    this.state,
    this.kycCompleted,
  });

  ProfileResponseModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int?,
      name = json['name'] as String?,
      maritalStatus = json['marital_status'] as String?,
      phone = json['phone'] as String?,
      countryCode = json['country_code'] as String?,
      hasPan = json['has_pan'] as bool?,
      hasAadhar = json['has_aadhar'] as bool?,
      otpVerified = json['otp_verified'] as bool?,
      profileStatus =
          (json['profile_status'] as String?)?.profileStatusToEnum(),
      hasWatchedTutorial = json['HasWatchedTutorial'] as bool?,
      isLegalDocumentSigned = json['IsLegalDocumentSigned'] as bool?,
      firstLanguage = json['first_language'] as String?,
      secondLanguage = json['second_language'] as String?,
      imagePath = json['image_path'] as String?,
      religion = json['religion'] as String?,
      signedLegalDocumentPath = json['signed_legal_document_path'] as String?,
      city = json['location'] as String?,
      state = json['state'] as String?,
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
    'image_path': imagePath,
    'religion': religion,
    'signed_legal_document_path': signedLegalDocumentPath,
    'location': city,
    'state': state,
    'kyc_completed': kycCompleted,
  };
}
