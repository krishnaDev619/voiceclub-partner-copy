import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/growthbook_service.dart';
import 'package:voiceclub_partner/domain/usecases/survey/check_survey_submission.dart';
import 'package:voiceclub_partner/modules/controller/call_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/survey/bottom_sheet/survey_bottom_sheet.dart';

/// Service to manage survey display logic with a 3-time limit for unsubmitted surveys.
///
/// This service ensures that surveys are shown to users a maximum of 3 times.
/// If a user hasn't submitted the survey after 3 attempts, it will no longer be shown.
/// The show count is tracked per survey ID using SharedPreferences.
/// When a user successfully submits a survey, the show count is reset for that survey.
class SurveyService {
  static const String _surveyShowCountKey = 'survey_show_count_';
  static const int _maxShowCount = 3;

  /// Checks if a survey should be shown and initiates it if conditions are met.
  ///
  /// This method:
  /// 1. Checks if the survey feature flag is enabled
  /// 2. Verifies the user is not on the chat screen or on a call
  /// 3. Fetches the current survey from GrowthBook
  /// 4. Checks if the user has already submitted this survey
  /// 5. Verifies the survey hasn't been shown 3 times already
  /// 6. Shows the survey bottom sheet if all conditions are met
  void checkAndInitiateSurvey() async {
    // Get the current survey from GrowthBook
    final surveyData = sl<GrowthBookService>().fetchSurveyFromGrowthBook();
    if (surveyData != null) {
      // Check if user has already submitted this survey
      final userId =
          Get.find<UserController>().userDetails.value.user?.id.toString() ??
          '';
      final surveyId = surveyData.id;

      if (userId.isNotEmpty && surveyId.isNotEmpty) {
        final hasSubmitted = await sl<CheckSurveySubmission>().call(
          CheckSurveySubmissionParams(userId: userId, surveyId: surveyId),
        );

        if (hasSubmitted.data == false) {
          // Check if we haven't exceeded the show limit for this survey
          final showCount = await _getShowCount(surveyId);
          if (showCount < _maxShowCount) {
            if (sl<GrowthBookService>().isFeatureEnabled(
                  FeatureFlag.surveypartner,
                ) &&
                Get.currentRoute == "/LandingScreen" &&
                !(Get.isBottomSheetOpen ?? false) &&
                !sl<CallController>().isOnCall) {
              Get.bottomSheet(
                SurveyBottomSheet(survey: surveyData, count: showCount),
                isScrollControlled: true,
              );
              // Increment the show count
              await _incrementShowCount(surveyId);
            }
          }
        }
      }
    }
  }

  /// Check if the survey can be shown based on the show count limit
  Future<int> _getShowCount(String surveyId) async {
    final prefs = await SharedPreferences.getInstance();
    final showCount = prefs.getInt('$_surveyShowCountKey$surveyId') ?? 0;
    return showCount;
  }

  /// Increment the show count for a specific survey
  Future<void> _incrementShowCount(String surveyId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt('$_surveyShowCountKey$surveyId') ?? 0;
    await prefs.setInt('$_surveyShowCountKey$surveyId', currentCount + 1);
  }

  /// Reset the show count for a specific survey (useful when user submits the survey)
  Future<void> resetShowCount(String surveyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_surveyShowCountKey$surveyId');
  }

  /// Get the current show count for a specific survey
  Future<int> getShowCount(String surveyId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_surveyShowCountKey$surveyId') ?? 0;
  }
}
