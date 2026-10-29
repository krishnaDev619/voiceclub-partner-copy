import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voiceclub_partner/core/constants/firestore_constants.dart';
import 'package:voiceclub_partner/core/services/logger.dart';
import 'package:voiceclub_partner/data/models/chat/chat_reply_message.dart';

class ChatFirebaseService {
  final db = FirebaseFirestore.instance;

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  fetchInitMessagesStream({required int chatGroupId, required int? limit}) {
    String id = chatGroupId.toString();
    Query<Map<String, dynamic>> query =
        limit == null
            ? FirebaseFirestore.instance
                .collection(FirestoreConstants.chatGroupCollection)
                .doc(id)
                .collection(FirestoreConstants.chatCollection)
                .orderBy('CreatedAt', descending: true)
                .limit(20)
            : FirebaseFirestore.instance
                .collection(FirestoreConstants.chatGroupCollection)
                .doc(id)
                .collection(FirestoreConstants.chatCollection)
                .orderBy('CreatedAt', descending: true)
                .limit(limit);

    final chatStream = query.snapshots();

    return chatStream.map((querySnapshot) {
      try {
        if (querySnapshot.docs.isNotEmpty) {
          // Map the query snapshot to a list of documents
          final documents = querySnapshot.docs;
          return documents;
        } else {
          // Handle the case where there are no documents
          return [];
        }
      } catch (e) {
        // Handle any errors that may occur during mapping
        throw ChatFirebaseException('Firebase Firestore error: $e');
      }
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchChatMessages({
    required int chatGroupId,
    required QueryDocumentSnapshot lastDocument,
  }) async {
    try {
      String id = chatGroupId.toString();
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection(FirestoreConstants.chatGroupCollection)
          .doc(id)
          .collection(FirestoreConstants.chatCollection)
          .orderBy('CreatedAt', descending: true)
          .startAfterDocument(lastDocument)
          .limit(20);

      final snapshots = await query.get();
      return snapshots;
    } catch (e) {
      throw ChatFirebaseException('Firebase Firestore error: $e');
    }
  }

  Future<int> fetchTotalMessageCount({required int chatGroupId}) async {
    try {
      String id = chatGroupId.toString();
      final count =
          await FirebaseFirestore.instance
              .collection(FirestoreConstants.chatGroupCollection)
              .doc(id)
              .collection(FirestoreConstants.chatCollection)
              .count()
              .get();
      return count.count ?? 0;
    } catch (e) {
      throw ChatFirebaseException('Firebase Firestore error: $e');
    }
  }

  Future<void> reportChatMessage({
    required int chatGroupId,
    required String documentId,
    String? reason,
  }) async {
    try {
      String groupId = chatGroupId.toString();
      DocumentReference userDocReference = FirebaseFirestore.instance
          .collection(FirestoreConstants.chatGroupCollection)
          .doc(groupId)
          .collection(FirestoreConstants.chatCollection)
          .doc(documentId);

      // Check if the document exists
      DocumentSnapshot<Object?> documentSnapshot = await userDocReference.get();
      if (documentSnapshot.exists) {
        // If the document exists, update the LastSeenAt field
        await userDocReference.update({
          "Content":
              "${FirestoreConstants.reportMessage}${(reason?.isNotEmpty ?? false) ? "\nReason: $reason" : ""}",
        });
      }
    } catch (_) {
      // Handle any errors that may occur during mapping
    }
  }

  /// Delete chat message
  /// Fetches the chat message and deletes it by adding a field isDeleted = true
  /// This is a soft delete, the message is not removed from the database
  Future<void> deleteChatMessage({
    required int chatGroupId,
    required String documentId,
  }) async {
    try {
      String groupId = chatGroupId.toString();
      DocumentReference userDocReference = FirebaseFirestore.instance
          .collection(FirestoreConstants.chatGroupCollection)
          .doc(groupId)
          .collection(FirestoreConstants.chatCollection)
          .doc(documentId);

      // Check if the document exists
      DocumentSnapshot<Object?> documentSnapshot = await userDocReference.get();
      if (documentSnapshot.exists) {
        // If the document exists, add an isDeleted field
        await userDocReference.update({"IsDeletedByPartner": true});
      }
    } catch (_) {
      // Handle any errors that may occur during mapping
    }
  }

  /// Update chat message
  /// Update reaction of a chat message
  Future<void> updateReaction({
    required int chatGroupId,
    required String documentId,
    required String reaction,
  }) async {
    try {
      String groupId = chatGroupId.toString();
      DocumentReference userDocReference = FirebaseFirestore.instance
          .collection(FirestoreConstants.chatGroupCollection)
          .doc(groupId)
          .collection(FirestoreConstants.chatCollection)
          .doc(documentId);

      // Check if the document exists
      DocumentSnapshot<Object?> documentSnapshot = await userDocReference.get();
      if (documentSnapshot.exists) {
        // If the document exists, add an isDeleted field
        await userDocReference.update({"Reaction": reaction});
      }
    } catch (e) {
      // Handle any errors that may occur during mapping
      Logger.logMessage(
        "Error in updateReaction ChatFirebaseService ${e.toString()}",
      );
    }
  }

  /// Update chat message reply
  /// Update reply of a chat message
  Future<void> updateReply({
    required int chatGroupId,
    required String documentId,
    required ChatReplyMessage replyMessage,
  }) async {
    try {
      String groupId = chatGroupId.toString();
      DocumentReference userDocReference = FirebaseFirestore.instance
          .collection(FirestoreConstants.chatGroupCollection)
          .doc(groupId)
          .collection(FirestoreConstants.chatCollection)
          .doc(documentId);

      // Check if the document exists
      DocumentSnapshot<Object?> documentSnapshot = await userDocReference.get();
      if (documentSnapshot.exists) {
        // If the document exists, add an isDeleted field
        await userDocReference.update({"ReplyMessage": replyMessage.toJson()});
      }
    } catch (e) {
      // Handle any errors that may occur during mapping
      Logger.logMessage(
        "Error in updateReaction ChatFirebaseService ${e.toString()}",
      );
    }
  }

  /// Fetch last seen timestamp stream for a chat group
  Stream<String?> fetchLastSeenMessageIdStream({required int chatGroupId}) {
    return FirebaseFirestore.instance
        .collection(FirestoreConstants.chatGroupCollection)
        .doc(chatGroupId.toString())
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            String? lastSeenMessageId = snapshot.data()?['lastSeenMessageId'];
            if (lastSeenMessageId != null) {
              return lastSeenMessageId;
            }
          }
          return null;
        });
  }
}

class ChatFirebaseException implements Exception {
  final String message;

  ChatFirebaseException(this.message);
}
