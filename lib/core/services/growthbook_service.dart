import 'package:growthbook_sdk_flutter/growthbook_sdk_flutter.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/url_constants.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/chat/growthbook_stickers_response.dart';
import 'package:voiceclub_partner/data/models/penaltywithdrawalexperiment/penalty_withdrawal_experiment_model.dart';
import 'package:voiceclub_partner/data/models/survey/survey_model.dart';

class GrowthBookService {
  final GrowthBookSDK gb;

  GrowthBookService(this.gb);

  bool isFeatureEnabled(FeatureFlag featureFlag) {
    try {
      return gb.feature(featureFlag.name.toLowerCase()).on;
    } catch (_) {
      return false;
    }
  }

  /// String value of the [FeatureFlag.xappkey] flag, used as the `X-App-Key`
  /// request header. Returns null when the flag is off or empty.
  String? getXAppKey() {
    try {
      const featureFlag = FeatureFlag.xappkey;
      if (!isFeatureEnabled(featureFlag)) {
        return null;
      }
      final value = gb.feature(featureFlag.name.toLowerCase()).value;
      if (value == null) {
        return null;
      }
      final key = value.toString().trim();
      return key.isEmpty ? null : key;
    } catch (_) {
      return null;
    }
  }

  bool _isFeatureEnabled(String featureFlag) {
    try {
      return gb.feature(featureFlag).on;
    } catch (_) {
      return false;
    }
  }

  List<String> getEnabledFeatures() {
    try {
      final featureMap = gb.features as Map<String, dynamic>?;
      final allFeatures = featureMap?.keys.toList() ?? [];
      final enabledFeatures = <String>[];
      if (allFeatures.isNotEmpty) {
        for (final feature in allFeatures) {
          if (_isFeatureEnabled(feature)) {
            enabledFeatures.add(feature);
          }
        }
      }
      return enabledFeatures;
    } catch (_) {
      return [];
    }
  }

  GrowthbookStickersResponseModel? getGrowthbookStickers() {
    try {
      const featureFlag = FeatureFlag.stickers;
      if (isFeatureEnabled(featureFlag)) {
        final json =
            gb.feature(featureFlag.name.toLowerCase()).value
                as Map<String, dynamic>? ??
            {};
        final stickersResponse = GrowthbookStickersResponseModel.fromJson(json);
        if (stickersResponse.stickers?.isNotEmpty ?? false) {
          return stickersResponse;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  String getSampleAudioUrl() {
    try {
      const featureFlag = FeatureFlag.sampleaudio;
      if (isFeatureEnabled(featureFlag)) {
        return (gb.feature(featureFlag.name.toLowerCase()).value as String?) ??
            URLConstants.defaultSampleAudio;
      } else {
        return URLConstants.defaultSampleAudio;
      }
    } catch (_) {
      return URLConstants.defaultSampleAudio;
    }
  }

  SurveyModel? fetchSurveyFromGrowthBook() {
    try {
      const featureFlag = FeatureFlag.surveypartner;
      if (isFeatureEnabled(featureFlag)) {
        final json =
            gb.feature(featureFlag.name.toLowerCase()).value
                as Map<String, dynamic>?;
        if (json?.isNotEmpty == true) {
          return SurveyModel.fromJson(json ?? {});
        }
      }
    } catch (e) {
      Logger.logMessage(
        "Failed to fetch survey from GrowthBook: $e",
        name: "GrowthBook",
      );
    }
    return null;
  }

  PenalyWithdrawalExperimentModel? fetchPenaltyWithdrawalExperiment() {
    try {
      const featureFlag = FeatureFlag.penaltywithdrawalexperiment;
      if (isFeatureEnabled(featureFlag)) {
        final json =
            gb.feature(featureFlag.name.toLowerCase()).value
                as Map<String, dynamic>?;
        if (json?.isNotEmpty == true) {
          return PenalyWithdrawalExperimentModel.fromJson(json ?? {});
        }
      }
    } catch (e) {
      Logger.logMessage(
        "Failed to fetch intro audio script from GrowthBook: $e",
        name: "GrowthBook",
      );
    }
    return null;
  }

  /// Retrieves a list of enabled features.
  ///
  /// Returns a list of strings representing the enabled features.
  Map<String, dynamic> getEnabledFeaturesWithValues() {
    final enabledFeatures = <String, dynamic>{};
    try {
      final featureMap = gb.features as Map<String, dynamic>?;
      final allFeatures = featureMap?.keys.toList() ?? [];
      if (allFeatures.isNotEmpty) {
        for (final feature in allFeatures) {
          if (_isFeatureEnabled(feature)) {
            enabledFeatures[feature] = gb.feature(feature).value;
          }
        }
      }
    } catch (_) {}
    return enabledFeatures;
  }

  void setAttributes({
    required int userId,
    required String? language,
    required String? secondaryLanguage,
    required PartnerCurrentStatus currentStatus,
    required int oneScore,
    required String createdAt,
  }) {
    final attrs = {
      "id": userId.toString(),
      "userId": userId,
      if (language != null && language.isNotEmpty) "language": language,
      if (secondaryLanguage != null && secondaryLanguage.isNotEmpty)
        "secondaryLanguage": secondaryLanguage,
      "partnerStatus": currentStatus.name,
      "oneScore": oneScore,
      "onboardingDate": createdAt,
    };
    gb.setAttributes(attrs);
  }
}
