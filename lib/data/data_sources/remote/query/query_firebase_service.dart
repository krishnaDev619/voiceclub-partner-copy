import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voiceclub_partner/core/constants/firestore_constants.dart';

class QueryFirebaseService {
  final db = FirebaseFirestore.instance;

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchQueryChatMessagesStream({required String sessionId}) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection(FirestoreConstants.queryChatCollection)
        .doc(sessionId)
        .collection(FirestoreConstants.messagesCollection)
        .orderBy('CreatedAt', descending: false);

    final chatStream = query.snapshots();

    return chatStream.map((querySnapshot) {
      try {
        if (querySnapshot.docs.isNotEmpty) {
          final documents = querySnapshot.docs;
          return documents;
        } else {
          return [];
        }
      } catch (e) {
        throw ChatFirebaseException('Firebase Firestore error: $e');
      }
    });
  }
}

class ChatFirebaseException implements Exception {
  final String message;

  ChatFirebaseException(this.message);
}
