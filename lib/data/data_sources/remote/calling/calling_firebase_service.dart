import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voiceclub_partner/core/constants/firestore_constants.dart';
import 'package:voiceclub_partner/core/services/logger.dart';

class CallingFirebaseService {
  final db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot> fetchCallStateStream({required String channelId}) {
    try {
      final Stream<DocumentSnapshot> callStream =
          FirebaseFirestore.instance
              .collection(FirestoreConstants.callCollection)
              .doc(channelId)
              .snapshots();

      return callStream;
    } catch (e) {
      // Handle any errors that may occur during streaming
      Logger.logMessage(
        "Error in fetchCallStateStream : ${e.toString()}",
        name: "CallingFirebaseService",
        isCritical: true,
      );
      throw CallingFirebaseException('Firebase Firestore error: $e');
    }
  }

  /// Listen to call entry stream against your account id
  Stream<DocumentSnapshot> fetchCallEntryStream({required String accountId}) {
    try {
      final Stream<DocumentSnapshot> callEntryStream = FirebaseFirestore
          .instance
          .collection(FirestoreConstants.partnerCallEntryCollection)
          .doc(accountId)
          .snapshots(includeMetadataChanges: true);

      return callEntryStream;
    } catch (e) {
      Logger.logMessage(
        "Error in fetchCallEntryStream : ${e.toString()}",
        name: "CallingFirebaseService",
        isCritical: true,
      );
      throw CallingFirebaseException('Firebase Firestore error: $e');
    }
  }
}

class CallingFirebaseException implements Exception {
  final String message;

  CallingFirebaseException(this.message);
}
