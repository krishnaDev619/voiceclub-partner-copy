import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/category_data.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';

class DataModel {
  final UserDataModel? user;
  final int? accountId;
  final CategoryDataModel? category;
  final String? primaryLanguage;
  final String? secondaryLanguage;
  final String? recordingUrl;
  final String? secondaryRecordingUrl;
  final String? audioGreetingUrl;
  final String? secondaryAudioGreetingUrl;
  final String? missedCallRecordingUrl;
  final String? secondaryMissedCallRecordingUrl;
  final String? chatSubscriptionUrl;
  final String? secondaryChatSubscriptionUrl;
  final String? fakeCallUrl;
  final String? status;
  final String? expertise;
  final String? prohibitionStatus;
  final String? featuresEnabled;
  final bool? isLanguageSelected;
  final int? kycCount;
  final bool? isAgencyPartner;
  final int? callCount;
  final bool? showCallCount;
  final int? limit;
  final bool? isLiveOnlyPartner;
  final String? kamName;
  final String? kamPhone;
  final bool? isBotKamNumber;
  final String? age;
  final String? education;
  final String? maritalStatus;
  final TutorialStage? onboardingStage;
  final String? onboardingStageChangeDate;
  final bool? onboardingStageTutorialCompleted;
  final int? flow;
  final PartnerCurrentStatus? previousStage;
  final PartnerCurrentStatus? currentStage;
  final String? stageChangeDate;
  final bool? aadharSignEligible;
  final bool? aadharSignDone;
  final bool? kycEligible;
  final bool? kycCompleted;
  final String? createdAt;

  DataModel({
    this.user,
    this.accountId,
    this.category,
    this.primaryLanguage,
    this.secondaryLanguage,
    this.recordingUrl,
    this.secondaryRecordingUrl,
    this.audioGreetingUrl,
    this.secondaryAudioGreetingUrl,
    this.missedCallRecordingUrl,
    this.secondaryMissedCallRecordingUrl,
    this.chatSubscriptionUrl,
    this.secondaryChatSubscriptionUrl,
    this.fakeCallUrl,
    this.status,
    this.expertise,
    this.prohibitionStatus,
    this.featuresEnabled,
    this.isLanguageSelected,
    this.kycCompleted,
    this.kycCount,
    this.isAgencyPartner,
    this.callCount,
    this.showCallCount,
    this.limit,
    this.isLiveOnlyPartner,
    this.kamName,
    this.kamPhone,
    this.isBotKamNumber,
    this.age,
    this.education,
    this.maritalStatus,
    this.onboardingStage,
    this.onboardingStageChangeDate,
    this.onboardingStageTutorialCompleted,
    this.flow,
    this.previousStage,
    this.currentStage,
    this.stageChangeDate,
    this.aadharSignEligible,
    this.aadharSignDone,
    this.kycEligible,
    this.createdAt,
  });

  DataModel.fromJson(Map<String, dynamic> json)
    : user =
          (json['user'] as Map<String, dynamic>?) != null
              ? UserDataModel.fromJson(json['user'] as Map<String, dynamic>)
              : null,
      accountId = json['account_id'] as int?,
      category =
          (json['category'] as Map<String, dynamic>?) != null
              ? CategoryDataModel.fromJson(
                json['category'] as Map<String, dynamic>,
              )
              : null,
      primaryLanguage = json['primary_language'] as String?,
      secondaryLanguage = json['secondary_language'] as String?,
      recordingUrl = json['recording_url'] as String?,
      secondaryRecordingUrl = json['secondary_recording_url'] as String?,
      audioGreetingUrl = json['audio_greeting_url'] as String?,
      secondaryAudioGreetingUrl =
          json['secondary_audio_greeting_url'] as String?,
      missedCallRecordingUrl = json['missed_call_recording_url'] as String?,
      secondaryMissedCallRecordingUrl =
          json['secondary_missed_call_recording_url'] as String?,
      chatSubscriptionUrl = json['chat_subscription_url'] as String?,
      secondaryChatSubscriptionUrl =
          json['secondary_chat_subscription_url'] as String?,
      fakeCallUrl = json['fake_call_url'] as String?,
      status = json['status'] as String?,
      expertise = json['expertise'] as String?,
      prohibitionStatus = json['prohibition_status'] as String?,
      isLanguageSelected = json['language_selected'] as bool?,
      featuresEnabled = json['features_enabled'] as String?,
      kycCompleted = json['kyc_completed'] as bool?,
      kycCount = json['kyc_count'] as int?,
      isAgencyPartner = json['is_agency_partner'] as bool?,
      callCount = json['call_count'] as int?,
      showCallCount = json['show_call_count'] as bool?,
      limit = json['limit'] as int?,
      isLiveOnlyPartner = json['is_live_only_partner'] as bool?,
      kamName = json['kam_name'] as String?,
      kamPhone = json['kam_phone'] as String?,
      isBotKamNumber = json['is_bot_kam_number'] as bool?,
      age = json['age'] as String?,
      education = json['education'] as String?,
      maritalStatus = json['marital_status'] as String?,
      onboardingStage =
          json['onboarding_stage'] != null
              ? (json['onboarding_stage'].toString()).toTutorialStage()
              : null,
      onboardingStageChangeDate =
          json['onboarding_stage_change_date'] as String?,
      onboardingStageTutorialCompleted =
          json['stage_course_completed'] as bool?,
      flow =
          json['sub_stage'] is int
              ? json['sub_stage'] as int?
              : int.tryParse(json['sub_stage']?.toString() ?? ''),
      previousStage =
          json['previous_stage'] != null
              ? (json['previous_stage'].toString()).toPartnerCurrentStatus()
              : null,
      currentStage =
          json['current_stage'] != null
              ? (json['current_stage'].toString()).toPartnerCurrentStatus()
              : null,
      stageChangeDate = json['stage_change_date'] as String?,
      aadharSignEligible = json['aadhar_sign_eligible'] as bool?,
      aadharSignDone = json['aadhar_sign_done'] as bool?,
      kycEligible = json['kyc_eligible'] as bool?,
      createdAt = json['created_at'] as String?;

  Map<String, dynamic> toJson() => {
    'user': user?.toJson(),
    'account_id': accountId,
    'category': category?.toJson(),
    'primary_language': primaryLanguage,
    'secondary_language': secondaryLanguage,
    'recording_url': recordingUrl,
    'secondary_recording_url': secondaryRecordingUrl,
    'audio_greeting_url': audioGreetingUrl,
    'secondary_audio_greeting_url': secondaryAudioGreetingUrl,
    'missed_call_recording_url': missedCallRecordingUrl,
    'secondary_missed_call_recording_url': secondaryMissedCallRecordingUrl,
    'chat_subscription_url': chatSubscriptionUrl,
    'secondary_chat_subscription_url': secondaryChatSubscriptionUrl,
    'fake_call_url': fakeCallUrl,
    'status': status,
    'expertise': expertise,
    'prohibition_status': prohibitionStatus,
    'features_enabled': featuresEnabled,
    'language_selected': isLanguageSelected,
    'kyc_completed': kycCompleted,
    'kyc_count': kycCount,
    'is_agency_partner': isAgencyPartner,
    'call_count': callCount,
    'show_call_count': showCallCount,
    'limit': limit,
    'is_live_only_partner': isLiveOnlyPartner,
    'kam_name': kamName,
    'kam_phone': kamPhone,
    'is_bot_kam_number': isBotKamNumber,
    'age': age,
    'education': education,
    'marital_status': maritalStatus,
    'onboarding_stage': onboardingStage?.name,
    'onboarding_stage_change_date': onboardingStageChangeDate,
    'stage_course_completed': onboardingStageTutorialCompleted,
    'sub_stage': flow,
    'previous_stage': previousStage,
    'current_stage': currentStage,
    'stage_change_date': stageChangeDate,
    'aadhar_sign_eligible': aadharSignEligible,
    'aadhar_sign_done': aadharSignDone,
    'kyc_eligible': kycEligible,
    'created_at': createdAt,
  };
}
