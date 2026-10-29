import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';
import 'package:voiceclub_partner/features/onboarding/data/models/auth/profile_response.dart';

class OnboardingDataModel {
  String? name;
  String? maritalStatus;
  String? phone;
  String? imagePath;
  bool? hasPan;
  bool? hasAadhar;
  String? firstLanguage;
  String? secondLanguage;
  String? age;
  String? education;
  String? religion;
  String? appLanguage;
  String? city;
  String? state;
  ProfileStatus? profileStatus;

  OnboardingDataModel({
    this.name,
    this.maritalStatus,
    this.phone,
    this.imagePath,
    this.hasPan,
    this.hasAadhar,
    this.firstLanguage,
    this.secondLanguage,
    this.age,
    this.education,
    this.religion,
    this.appLanguage,
    this.city,
    this.state,
    this.profileStatus,
  });

  OnboardingDataModel.fromProfileResponseModel(
    ProfileResponseModel profileResponseModel,
  ) : name = profileResponseModel.name ?? "",
      maritalStatus = profileResponseModel.maritalStatus ?? "",
      phone = profileResponseModel.phone ?? "",
      hasPan = profileResponseModel.hasPan ?? false,
      hasAadhar = profileResponseModel.hasAadhar ?? false,
      firstLanguage = profileResponseModel.firstLanguage ?? "",
      secondLanguage = profileResponseModel.secondLanguage ?? "",
      imagePath = profileResponseModel.imagePath ?? "",
      religion = profileResponseModel.religion ?? "",
      city = profileResponseModel.city ?? "",
      state = profileResponseModel.state ?? "",
      profileStatus = profileResponseModel.profileStatus;

  OnboardingDataModel.fromJson(Map<String, dynamic> json)
    : name = json['name'] as String?,
      maritalStatus = json['marital_status'] as String?,
      phone = json['phone'] as String?,
      imagePath = json['image_path'] as String?,
      hasPan = json['has_pan'] as bool?,
      hasAadhar = json['has_aadhar'] as bool?,
      firstLanguage = json['first_language'] as String?,
      secondLanguage = json['second_language'] as String?,
      age = json['age'] as String?,
      education = json['education'] as String?,
      religion = json['religion'] as String?,
      city = json['location'] as String?,
      state = json['state'] as String?,
      appLanguage = json['app_language'] as String?,
      profileStatus =
          (json['profile_status'] as String?)?.profileStatusToEnum();

  Map<String, dynamic> toJson() => {
    'name': name,
    'marital_status': maritalStatus,
    'phone': phone,
    'image_path': imagePath,
    'has_pan': hasPan,
    'has_aadhar': hasAadhar,
    'first_language': firstLanguage,
    'second_language': secondLanguage,
    'age': age,
    'education': education,
    'religion': religion,
    'app_language': appLanguage,
    'location': city,
    'state': state,
    'profile_status': profileStatus?.name,
  };
}
