import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voiceclub_partner/data/models/rating/rating_model.dart';
import 'package:voiceclub_partner/view/partner_profile/widgets/rating_bottom_sheet.dart';

class RatingService {
  static const String _prefsKey = 'ratedAccountIds';

  static void addSupplyRating(
    int accountId,
    String name,
    String avatar,
    String callDuration,
    BuildContext context,
    bool isDemand,
    String category,
  ) async {
    bool isRated = await isAccountRated(accountId);
    if (!isRated) {
      Get.bottomSheet(
        RatingBottomSheet(
          name: name,
          avatar: avatar,
          callDuration: callDuration,
          accountId: accountId,
          category: category,
        ),
        isScrollControlled: false,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
      );
    }
  }

  static Future<void> storeRatedAccountIds(List<RatingModel> ratings) async {
    final prefs = await SharedPreferences.getInstance();
    final accountIds = ratings.map((rating) => rating.accountId).toList();
    prefs.setStringList(
      _prefsKey,
      accountIds.map((id) => id.toString()).toList(),
    );
  }

  static Future<List<int>> getRatedAccountIds() async {
    final prefs = await SharedPreferences.getInstance();
    final storedIds = prefs.getStringList(_prefsKey);
    return storedIds?.map((id) => int.tryParse(id) ?? 0).toList() ?? [];
  }

  static Future<void> addRatedAccountId(int accountId) async {
    final prefs = await SharedPreferences.getInstance();
    final storedIds = await getRatedAccountIds();
    if (!storedIds.contains(accountId)) {
      storedIds.add(accountId);
      prefs.setStringList(
        _prefsKey,
        storedIds.map((id) => id.toString()).toList(),
      );
    }
  }

  static Future<bool> isAccountRated(int accountId) async {
    final storedIds = await getRatedAccountIds();
    return storedIds.contains(accountId);
  }
}
