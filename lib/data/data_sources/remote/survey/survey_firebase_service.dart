import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voiceclub_partner/core/constants/firestore_constants.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/survey/user_survey_submissions_model.dart';

class SurveyFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if a user has submitted a specific survey
  Future<bool> hasUserSubmittedSurvey({
    required String userId,
    required String surveyId,
  }) async {
    try {
      final doc =
          await _firestore
              .collection(FirestoreConstants.surveyCollection)
              .doc(userId)
              .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data();
      if (data == null) {
        return false;
      }

      final submissions = UserSurveySubmissionsModel.fromJson(data);
      return submissions.submittedSurveyIds.contains(surveyId);
    } catch (e) {
      Logger.logMessage('Error checking survey submission: $e');
      return false;
    }
  }

  /// Mark a survey as submitted for a user
  Future<void> markSurveyAsSubmitted({
    required String userId,
    required String surveyId,
  }) async {
    try {
      final docRef = _firestore
          .collection(FirestoreConstants.surveyCollection)
          .doc(userId);

      await docRef.set({
        "submittedSurveyIds": FieldValue.arrayUnion([surveyId]),
      }, SetOptions(merge: true));
    } catch (e) {
      Logger.logMessage('Error marking survey as submitted: $e');
      rethrow;
    }
  }

  /// Get all submitted surveys for a user
  Future<List<String>> getUserSubmittedSurveys({required String userId}) async {
    try {
      final doc =
          await _firestore
              .collection(FirestoreConstants.surveyCollection)
              .doc(userId)
              .get();

      if (!doc.exists) {
        return [];
      }

      final data = doc.data();
      if (data == null) {
        return [];
      }

      final submissions = UserSurveySubmissionsModel.fromJson(data);
      return submissions.submittedSurveyIds;
    } catch (e) {
      Logger.logMessage('Error getting user submitted surveys: $e');
      return [];
    }
  }

  /// Get user survey submissions model
  Future<UserSurveySubmissionsModel?> getUserSurveySubmissions({
    required String userId,
  }) async {
    try {
      final doc =
          await _firestore
              .collection(FirestoreConstants.surveyCollection)
              .doc(userId)
              .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      if (data == null) {
        return null;
      }

      return UserSurveySubmissionsModel.fromJson(data);
    } catch (e) {
      Logger.logMessage('Error getting user survey submissions: $e');
      return null;
    }
  }
}
