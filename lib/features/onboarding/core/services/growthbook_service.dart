import 'package:growthbook_sdk_flutter/growthbook_sdk_flutter.dart';
import 'package:voiceclub_partner/features/onboarding/core/constants/enums.dart';

class GrowthBookService {
  final GrowthBookSDK gb;

  GrowthBookService(this.gb);

  /// Checks if a given feature flag is enabled.
  ///
  /// This method attempts to retrieve the feature flag status from the GrowthBook
  /// service. If the feature flag is found and enabled, it returns `true`.
  /// If the feature flag is not found or an error occurs, it returns `false`.
  ///
  /// [featureFlag] The feature flag to check.
  ///
  /// Returns `true` if the feature flag is enabled, `false` otherwise.
  bool isFeatureEnabled(FeatureFlag featureFlag) {
    try {
      return gb.feature(featureFlag.name.toLowerCase()).on;
    } catch (_) {
      return false;
    }
  }

  bool _isFeatureEnabled(String featureFlag) {
    try {
      return gb.feature(featureFlag).on;
    } catch (_) {
      return false;
    }
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
          if (FeatureFlag.values
              .map((e) => e.name.toLowerCase())
              .toList()
              .contains(feature.toLowerCase())) {
            if (_isFeatureEnabled(feature)) {
              enabledFeatures[feature] = gb.feature(feature).value;
            }
          }
        }
      }
    } catch (_) {}
    return enabledFeatures;
  }

  void setAttributes({
    required String phoneNumber,
    required String appLanguage,
  }) {
    final attrs = {"id": phoneNumber, "appLanguage": appLanguage};
    gb.setAttributes(attrs);
  }
}
