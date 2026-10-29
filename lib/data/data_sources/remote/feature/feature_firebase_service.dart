import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voiceclub_partner/core/constants/firestore_constants.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

class FeatureFirebaseService {
  final _firestore = FirebaseFirestore.instance;

  /// Updates the lastSeenTime when the partner views the feature video
  Future<void> updateLastSeenTime({required String accountId}) async {
    try {
      await _firestore
          .collection(FirestoreConstants.featureCollection)
          .doc(accountId)
          .set({
            'lastSeenTime': DateTime.now().toIso8601String(),
          }, SetOptions(merge: true));
    } catch (e) {
      Logger.logMessage("Error updating lastSeenTime: $e");
    }
  }

  /// Fetches the lastSeenTime (if needed to check whether to show video again)
  Future<DateTime?> getLastSeenTime({required String accountId}) async {
    try {
      final snapshot =
          await _firestore
              .collection(FirestoreConstants.featureCollection)
              .doc(accountId)
              .get();
      if (snapshot.exists && snapshot.data() != null) {
        final time = snapshot['lastSeenTime'] as String?;
        return DateTime.tryParse(time ?? '');
      } else {
        updateLastSeenTime(accountId: accountId);
      }
    } catch (e) {
      Logger.logMessage("Error fetching lastSeenTime: $e");
    }
    return null;
  }

  /// Checks if the user has seen the WhatsApp group sheet
  Future<bool> hasSeenWhatsAppGroup({required String accountId}) async {
    try {
      final snapshot =
          await _firestore
              .collection(FirestoreConstants.featureCollection)
              .doc(accountId)
              .get();
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()?['hasSeenWhatsAppGroup'] ?? false;
      }
      return false;
    } catch (e) {
      Logger.logMessage("Error checking hasSeenWhatsAppGroup: $e");
      return false;
    }
  }

  /// Marks the WhatsApp group sheet as seen for the user
  Future<void> markWhatsAppGroupAsSeen({required String accountId}) async {
    try {
      await _firestore
          .collection(FirestoreConstants.featureCollection)
          .doc(accountId)
          .set({'hasSeenWhatsAppGroup': true}, SetOptions(merge: true));
    } catch (e) {
      Logger.logMessage("Error marking WhatsApp group as seen: $e");
    }
  }
}

class FeatureFirebaseException implements Exception {
  final String message;

  FeatureFirebaseException(this.message);
}
