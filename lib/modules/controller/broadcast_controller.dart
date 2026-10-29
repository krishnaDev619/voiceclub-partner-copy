import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/broadcast_message_service.dart';
import 'package:voiceclub_partner/data/models/chat/chat_filter.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_filtered_chat_groups.dart';
import 'package:voiceclub_partner/domain/usecases/chat/send_broadcast_message.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/view/auth/widgets/cancel_alert.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class BroadcastController extends GetxController {
  final ChatFilter broadcastFilter;
  final CategoryCode categoryCode;

  BroadcastController({
    required this.categoryCode,
    required this.broadcastFilter,
  });

  final isLoading = false.obs;
  final _filteredGroups = <ChatGroup>{}.obs;
  final matchingFilteredGroups = <ChatGroup>{}.obs;
  final totalFilteredPages = 0.obs;
  final totalFilteredItems = 0.obs;
  final alreadyBroadcastIDs = <int>{}.obs;
  final broadcastList = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFilteredChats(page: 1);
  }

  void fetchFilteredChats({required int page}) async {
    try {
      if (page == 1) {
        isLoading(true);
        alreadyBroadcastIDs.clear();
        alreadyBroadcastIDs.addAll(
          await BroadcastMessageService.fetchTodayBroadcastedGroupIds(),
        );
        totalFilteredPages.value = 1;
        _filteredGroups.clear();
        matchingFilteredGroups.clear();
      }
      if (page <= totalFilteredPages.value) {
        final response = await sl<GetFilteredChatGroupsUsecase>().call(
          GetFilteredChatGroupsParams(
            code: broadcastFilter.filterCode,
            page: page,
            pageSize: 25,
            isCount: false,
          ),
        );
        if (response.data != null && response.error == null) {
          totalFilteredPages.value = response.data?.totalPages ?? 1;
          totalFilteredItems.value = response.data?.totalItems ?? 0;
          final newChatGroups = response.data?.groups ?? [];
          final sortedGroups = newChatGroups.toList();
          // Sort groups - move already broadcast groups to end
          sortedGroups.sort((a, b) {
            final aIsBroadcast =
                a.id != null && alreadyBroadcastIDs.contains(a.id);
            final bIsBroadcast =
                b.id != null && alreadyBroadcastIDs.contains(b.id);
            return aIsBroadcast == bIsBroadcast
                ? 0
                : aIsBroadcast
                ? 1
                : -1;
          });
          _filteredGroups.addAll(sortedGroups);
          matchingFilteredGroups.addAll(_filteredGroups);
        }
      }
    } catch (_) {
    } finally {
      if (page == 1) {
        isLoading(false);
      }
    }
  }

  void searchFilteredChats(String query) {
    if (query.isEmpty) {
      // If the query is empty, display all groups in filteredGroups
      matchingFilteredGroups.assignAll(_filteredGroups);
    } else {
      // If the query is not empty, filter groups based on the query
      final matchingGroups =
          _filteredGroups.where((group) {
            final groupName = group.title?.toLowerCase() ?? '';
            return groupName.contains(query.toLowerCase());
          }).toList();

      matchingFilteredGroups.assignAll(matchingGroups);
    }
  }

  Future<void> handleBroadcastMessage({
    String? message,
    required ChatType messageType,
    File? attachment,
  }) async {
    try {
      if (broadcastList.isEmpty) {
        return;
      }
      bool? result = await Get.dialog(
        CancelAlertDialog(
          title: LocaleKeys.liveSendBroadcast.tr,
          subtitle:
              "Are you sure you want to send this message to ${broadcastList.length} users?",
        ),
      );

      if (result != true) return;

      // Close the bottom sheet immediately
      Get.back();

      Get.snackbar(
        LocaleKeys.liveSendingBroadcast.trParams({
          'count': '${broadcastList.length}',
        }),
        LocaleKeys.liveNotifyWhenSent.tr,
        duration: const Duration(days: 1), // Keep until dismissed
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(10),
        backgroundColor: const Color(0xFFEF8D32),
        colorText: Colors.white,
        borderRadius: 16.0,
        icon: Container(
          margin: const EdgeInsets.only(left: 16.0, right: 8.0),
          height: 18.0,
          width: 18.0,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.0,
          ),
        ),
        mainButton: TextButton(
          onPressed: () => Get.closeCurrentSnackbar(),
          child: const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Icon(Icons.close, color: Colors.white),
          ),
        ),
      );

      bool error = false;
      String? attachmentUrl;
      try {
        final result = await sl<SendBroadcastMessageUsecase>().call(
          SendBroadcastMessageParams(
            groupIds: broadcastList.toList(),
            messageType: messageType,
            message: message ?? ' ',
            attachment: attachment,
          ),
        );
        if (result.error != null) {
          error = true;
        } else {
          attachmentUrl = result.data;
        }
      } catch (_) {
        error = true;
      } finally {
        // Close the sticky notification
        Get.closeCurrentSnackbar();

        if (error) {
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Error,
            title: LocaleKeys.somethingWentWrong.tr,
            subtitle: LocaleKeys.pleaseTryAgainLater.tr,
          );
        } else {
          sl<AnalyticsService>().trackEvent(
            "broadcastSuccess",
            eventProperties: {
              'count': broadcastList.length,
              'filterCode': broadcastFilter.filterCode,
              'groupIds': broadcastList.toList(),
              'content': message,
              'type': messageType.name,
              if (attachmentUrl?.isNotEmpty ?? false)
                'attachmentUrl': attachmentUrl,
            },
          );
          BroadcastMessageService.saveBroadcast(broadcastList.toList());
          AlertService.showSnackBar(
            snackBarType: SnackBarType.Success,
            title: LocaleKeys.liveBroadcastMessageSent.tr,
            subtitle: LocaleKeys.liveYourMessageWasSentTo.tr,
          );
          Get.find<ChatOverviewController>().fetchChats(page: 1);
        }
      }
    } catch (_) {}
  }
}
