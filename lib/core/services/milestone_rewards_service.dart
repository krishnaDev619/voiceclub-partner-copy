import 'package:shared_preferences/shared_preferences.dart';

class MilestoneRewardsService {
  static const String _shownRewardsKey = 'shown_milestone_rewards';
  static const String _shownLifetimeRewardsKey = 'shown_lifetime_rewards';
  static const String _shownClaimedGiftDialogKey = 'shown_claimed_gift_dialog';

  /// Fetch rewards that have already been shown
  static Future<Set<int>> _getShownRewards() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_shownRewardsKey)?.map(int.parse).toSet() ?? {};
  }

  /// Mark a reward as shown
  static Future<void> markRewardAsShown(int rewardId) async {
    final prefs = await SharedPreferences.getInstance();
    final shownRewards = await _getShownRewards();
    shownRewards.add(rewardId);
    await prefs.setStringList(
      _shownRewardsKey,
      shownRewards.map((e) => e.toString()).toList(),
    );
  }

  /// Check if a reward has already been shown
  static Future<bool> isRewardShown(int rewardId) async {
    final shownRewards = await _getShownRewards();
    return shownRewards.contains(rewardId);
  }

  /// Fetch rewards that have already been shown
  static Future<Set<int>> _getShownLifetimeRewards() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
            .getStringList(_shownLifetimeRewardsKey)
            ?.map(int.parse)
            .toSet() ??
        {};
  }

  /// Mark a reward as shown
  static Future<void> markLifetimeRewardAsShown(int rewardId) async {
    final prefs = await SharedPreferences.getInstance();
    final shownRewards = await _getShownLifetimeRewards();
    shownRewards.add(rewardId);
    await prefs.setStringList(
      _shownLifetimeRewardsKey,
      shownRewards.map((e) => e.toString()).toList(),
    );
  }

  /// Check if a reward has already been shown
  static Future<bool> isLifetimeRewardShown(int rewardId) async {
    final shownRewards = await _getShownLifetimeRewards();
    return shownRewards.contains(rewardId);
  }

  /// Check if claimed gift dialog has been shown for a specific gift
  static Future<bool> isClaimedGiftDialogShown(int giftId) async {
    final prefs = await SharedPreferences.getInstance();
    final shownDialogs =
        prefs
            .getStringList(_shownClaimedGiftDialogKey)
            ?.map(int.parse)
            .toSet() ??
        {};
    return shownDialogs.contains(giftId);
  }

  /// Mark claimed gift dialog as shown for a specific gift
  static Future<void> markClaimedGiftDialogAsShown(int giftId) async {
    final prefs = await SharedPreferences.getInstance();
    final shownDialogs = await _getShownClaimedGiftDialogs();
    shownDialogs.add(giftId);
    await prefs.setStringList(
      _shownClaimedGiftDialogKey,
      shownDialogs.map((e) => e.toString()).toList(),
    );
  }

  /// Get all claimed gift dialogs that have been shown
  static Future<Set<int>> _getShownClaimedGiftDialogs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
            .getStringList(_shownClaimedGiftDialogKey)
            ?.map(int.parse)
            .toSet() ??
        {};
  }
}
