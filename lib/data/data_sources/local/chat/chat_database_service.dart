import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';

class ChatDatabaseService {
  final Box<List> chatGroupBox;
  final Box<int> messageCountBox;
  final Box<int> fetchedMessageCountBox;
  final Box<double> scrollPositionBox;

  ChatDatabaseService(
    this.chatGroupBox,
    this.messageCountBox,
    this.scrollPositionBox,
    this.fetchedMessageCountBox,
  );

  void saveChatGroupsToDatabase({
    required List<ChatGroup> chatGroups,
    required ChatTabFilter filter,
  }) {
    try {
      chatGroupBox.put(filter.name, chatGroups);
    } catch (_) {}
  }

  List<ChatGroup> getChatGroupsFromDatabase({required ChatTabFilter filter}) {
    try {
      final chatGroups =
          chatGroupBox
              .get(filter.name, defaultValue: <ChatGroup>[])
              ?.cast<ChatGroup>() ??
          [];
      return chatGroups;
    } catch (_) {
      return [];
    }
  }

  void deleteChatGroupsFromDatabase({required ChatTabFilter filter}) {
    try {
      chatGroupBox.delete(filter.name);
    } catch (_) {}
  }

  int? getLocalMessageCount({required int chatGroupId}) {
    try {
      return messageCountBox.get(chatGroupId);
    } catch (_) {
      return null;
    }
  }

  void saveLocalMessageCount({required int chatGroupId, required int count}) {
    try {
      messageCountBox.put(chatGroupId, count);
    } catch (_) {}
  }

  int? getLocalFetchedMessageCount({required int chatGroupId}) {
    try {
      return fetchedMessageCountBox.get(chatGroupId);
    } catch (_) {
      return null;
    }
  }

  void saveLocalFetchedMessageCount({
    required int chatGroupId,
    required int count,
  }) {
    try {
      fetchedMessageCountBox.put(chatGroupId, count);
    } catch (_) {}
  }

  void saveScrollPosition({
    required int chatGroupId,
    required double scrollPosition,
  }) {
    try {
      // Save the updated list of scroll positions
      scrollPositionBox.put(chatGroupId, scrollPosition);
      // Ensure that only the most recent two scroll positions are stored
      if (scrollPositionBox.length > 3) {
        // Remove the oldest scroll position
        scrollPositionBox.deleteAt(0);
      }
    } catch (_) {}
  }

  double getScrollPosition({required int chatGroupId}) {
    try {
      // Get the list of saved scroll positions for the given chatGroupId
      double scrollPosition = scrollPositionBox.get(chatGroupId) ?? 0;
      return scrollPosition;
    } catch (_) {
      return 0.0;
    }
  }
}
