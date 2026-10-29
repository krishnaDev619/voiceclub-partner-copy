import 'package:get/get.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/data_state.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/core/services/survey_service.dart';
import 'package:voiceclub_partner/data/models/survey/survey_model.dart';
import 'package:voiceclub_partner/data/models/survey/survey_response_model.dart';
import 'package:voiceclub_partner/domain/usecases/survey/mark_survey_submitted.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';

class SurveyController extends GetxController {
  final SurveyModel survey;
  final int count;

  SurveyController({required this.survey, required this.count}) {
    _fireSurveyEvent('surveyOpenPartner');
  }

  RxInt currentIndex = 0.obs;
  RxList<SurveyResponseModel> responses = <SurveyResponseModel>[].obs;
  RxBool isCompleted = false.obs;
  RxBool isStarted = false.obs;

  void answerCurrent(dynamic answer) {
    try {
      final question = survey.questions[currentIndex.value];
      responses.removeWhere((r) => r.questionId == question.id);
      responses.add(
        SurveyResponseModel(questionId: question.id, answer: answer),
      );
    } catch (e) {
      Logger.logMessage('Error answering current question: $e');
    }
  }

  void next() async {
    if (!isStarted.value) {
      isStarted.value = true;
      return;
    }

    // Fire analytics event for question response before moving to next
    if (isStarted.value && currentIndex.value < survey.questions.length) {
      final question = survey.questions[currentIndex.value];
      final response = responses.firstWhereOrNull(
        (r) => r.questionId == question.id,
      );
      Logger.logMessage('Response: $response');
      if (response != null) {
        Logger.logMessage(
          'Firing survey question response event with properties: ${question.toJson()}, ${response.answer}, ${currentIndex.value}',
        );
        _fireSurveyEvent(
          'surveyQuestionResponsePartner',
          additionalProperties: {
            'question': question.toJson(),
            'answer': response.answer,
            'question_index': currentIndex.value,
          },
        );
      }
    }

    if (currentIndex.value < (survey.questions.length - 1)) {
      currentIndex.value++;
    } else {
      isCompleted.value = true;
      await _markSurveyAsSubmitted();
    }
  }

  Future<void> _markSurveyAsSubmitted() async {
    try {
      final userId =
          Get.find<UserController>().userDetails.value.user?.id.toString() ??
          '';
      final surveyId = survey.id;

      if (userId.isNotEmpty && surveyId.isNotEmpty) {
        final result = await sl<MarkSurveySubmitted>().call(
          MarkSurveySubmittedParams(userId: userId, surveyId: surveyId),
        );

        // If survey was successfully submitted, reset the show count
        if (result is DataSuccess) {
          // Success case
          await sl<SurveyService>().resetShowCount(surveyId);

          // Fire analytics event for survey submission with all answers
          _fireSurveyEvent('surveySubmittedPartner');
        }
      }
    } catch (e) {
      Logger.logMessage('Error marking survey as submitted: $e');
    }
  }

  void previous() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }

  void reset() {
    currentIndex.value = 0;
    responses.clear();
    isCompleted.value = false;
    isStarted.value = false;
  }

  void _fireSurveyEvent(
    String eventName, {
    Map<String, dynamic>? additionalProperties,
  }) {
    try {
      sl<AnalyticsService>().trackEvent(
        eventName,
        eventProperties: {
          'survey_id': survey.id,
          'survey_type': survey.type.toString(),
          'survey_questions': survey.questions.map((e) => e.toJson()).toList(),
          'survey_target': survey.target,
          'survey_active': survey.active,
          'survey_date': survey.date,
          'attempt_count': count + 1,
          ...additionalProperties ?? {},
        },
      );
    } catch (e) {
      Logger.logMessage('Error firing survey event: $eventName:::::: $e');
    }
  }
}
