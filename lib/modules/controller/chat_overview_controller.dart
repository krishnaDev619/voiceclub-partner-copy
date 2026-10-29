import 'dart:async';

import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/chat/active_account_model.dart';
import 'package:voiceclub_partner/data/models/chat/chat_filter.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/data/models/chat/pending_audio.dart';
import 'package:voiceclub_partner/domain/usecases/chat/fetch_unseen_count.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_active_users.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_filter_options.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_group_by_account_id.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_groups.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_chat_groups_from_database.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_filtered_chat_groups.dart';
import 'package:voiceclub_partner/domain/usecases/chat/get_pending_audios.dart';
import 'package:voiceclub_partner/domain/usecases/chat/save_chat_groups_to_database.dart';
import 'package:voiceclub_partner/domain/usecases/chat/search_chat_groups.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/chat/chat_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class ChatOverviewController extends GetxController {
  final CategoryCode categoryCode;

  ChatOverviewController({required this.categoryCode});

  final groups = <ChatGroup>{}.obs;
  final activeUsers = <ActiveAccount>{}.obs;
  final unseenCount = 0.obs;
  final totalPages = 0.obs;
  final totalItems = 0.obs;
  final isLoading = false.obs;
  final filterOptions = <ChatFilter>[].obs;
  final selectedChatTabFilter = ChatTabFilter.ALL.obs;
  final replyCount = 0.obs;
  final pendingAudios = <PendingAudio>{}.obs;

  @override
  void onInit() {
    fetchInitChats();
    super.onInit();
  }

  Future<void> fetchInitChats() async {
    totalPages.value = 1;
    groups.clear();
    fetchChatFilterOptions();
    fetchChats(page: 1, init: true);
    fetchActiveUsers();
  }

  Future<void> fetchChatFilterOptions() async {
    try {
      final response = await sl<GetChatFilterOptionsUsecase>().call(
        GetChatFilterOptionsParams(categoryCode: categoryCode),
      );
      if (response.data != null && response.error == null) {
        filterOptions.assignAll(response.data?.filters ?? []);
      }
    } catch (_) {}
  }

  Future<void> fetchChats({
    required int page,
    String query = '',
    bool init = false,
  }) async {
    if (page == 1) {
      fetchPendingAudios();
      isLoading(true);
      totalPages.value = 1;
      groups.clear();
      update();
    }
    if (page <= (totalPages.value)) {
      try {
        final response =
            query.isNotEmpty
                ? await sl<SearchChatGroupsUsecase>().call(
                  SearchChatGroupsParams(
                    category: categoryCode.name,
                    page: page,
                    pageSize: 30,
                    searchQuery: query,
                  ),
                )
                : (selectedChatTabFilter.value != ChatTabFilter.ALL
                    ? await sl<GetFilteredChatGroupsUsecase>().call(
                      GetFilteredChatGroupsParams(
                        code: selectedChatTabFilter.value.name.toUpperCase(),
                        page: page,
                        pageSize: 30,
                        isCount: false,
                      ),
                    )
                    : await sl<GetChatGroupsUsecase>().call(
                      GetChatGroupsParams(
                        category: categoryCode.name,
                        page: page,
                        pageSize: 30,
                      ),
                    ));
        if (response.data != null) {
          totalPages.value = response.data?.totalPages ?? 1;
          totalItems.value = response.data?.totalItems ?? 0;
          if (selectedChatTabFilter.value == ChatTabFilter.UNREAD_TO_REPLY) {
            replyCount.value = totalItems.value;
          }
          final newChatGroups = response.data?.groups ?? [];
          // if (page == 1) {
          //   await deleteChatGroupsFromDatabaseUsecase
          //       .call(delete.Params(filter: selectedChatTabFilter.value));
          // }
          final dbGroups =
              query.isNotEmpty
                  ? <ChatGroup>[]
                  : await sl<GetChatGroupsFromDatabaseUsecase>().call(
                    GetChatGroupsFromDatabaseParams(
                      filter: selectedChatTabFilter.value,
                    ),
                  );

          final dbGroupsMap = {for (var group in dbGroups) group.id: group};

          // Prepare a new ordered list based on the server response
          final orderedGroups = <ChatGroup>[];

          for (final newChatGroup in newChatGroups) {
            if (dbGroupsMap.containsKey(newChatGroup.id)) {
              // Update the existing group with the server response while preserving local fields
              final existingChatGroup = dbGroupsMap[newChatGroup.id]!;
              final updatedChatGroup =
                  existingChatGroup.chatTheme != newChatGroup.chatTheme
                      ? newChatGroup.copyWith(
                        chatThemeId: existingChatGroup.chatThemeId,
                      )
                      : newChatGroup;

              orderedGroups.add(updatedChatGroup);
            } else {
              // Add new groups from the server
              orderedGroups.add(newChatGroup);
            }
          }

          // Remove stale groups from the database
          final serverGroupIds = newChatGroups.map((group) => group.id).toSet();
          dbGroupsMap.removeWhere((id, _) => !serverGroupIds.contains(id));
          groups.addAll(orderedGroups.toSet());

          await sl<SaveChatGroupsToDatabaseUsecase>().call(
            SaveChatGroupsToDatabaseParams(
              chatGroups: groups.toList(),
              filter: selectedChatTabFilter.value,
            ),
          );
          if (init) {
            final totalGroups = groups.length;
            final unseenGroups =
                groups
                    .where((element) => ((element.unseenCount ?? 0) > 0))
                    .length;
            final seenGroups = totalGroups - unseenGroups;
            sl<AnalyticsService>().trackEvent(
              '${categoryCode.camelCaseCategoryName}ChatHomeScreen',
              eventProperties: {
                'unseenMessagesCount': unseenGroups,
                'seenMessagesCount': seenGroups,
              },
            );
          }
          fetchReplyCount();
          fetchUnseenCount();
        } else {
          final dbGroups = await sl<GetChatGroupsFromDatabaseUsecase>().call(
            GetChatGroupsFromDatabaseParams(
              filter: selectedChatTabFilter.value,
            ),
          );
          groups(dbGroups.toSet());
        }
      } catch (_) {
      } finally {
        isLoading(false);
        update();
      }
    }
  }

  void fetchActiveUsers() async {
    try {
      final response = await sl<GetActiveUsersUseCase>().call(NoParams());
      if (response.data != null) {
        activeUsers((response.data?.accounts ?? []).toSet());
      }
    } catch (_) {}
  }

  void fetchReplyCount() async {
    if (categoryCode == CategoryCode.GOSSIP) {
      const tabFilter = ChatTabFilter.UNREAD_TO_REPLY;
      final response = await sl<GetFilteredChatGroupsUsecase>().call(
        GetFilteredChatGroupsParams(
          code: tabFilter.name.toUpperCase(),
          page: 1,
          pageSize: 10,
          isCount: true,
        ),
      );
      if (response.data != null && response.error == null) {
        replyCount.value = response.data?.totalItems ?? 0;
      }
    }
  }

  void changeChatTab(ChatTabFilter newFilter) {
    if (selectedChatTabFilter.value != newFilter) {
      selectedChatTabFilter(newFilter);
      update();
      fetchChats(page: 1);
    }
  }

  void fetchUnseenCount() async {
    final response = await sl<FetchUnseenCountUsecase>().call(
      FetchUnseenCountParams(categoryCode: categoryCode),
    );
    if (response.data?.count != null) {
      unseenCount.value = response.data?.count ?? 0;
      update();
    }
  }

  Future<void> fetchPendingAudios() async {
    try {
      if (categoryCode == CategoryCode.GOSSIP) {
        final response = await sl<GetPendingAudiosUseCase>().call(NoParams());
        if (response.data != null && response.error == null) {
          pendingAudios.clear();
          for (final audio in response.data?.audios ?? <PendingAudio>[]) {
            pendingAudios.addIf(((audio.timeLeftInSecs ?? 0) > 0), audio);
          }
        }
      }
    } catch (_) {
      pendingAudios.clear();
    } finally {
      update();
    }
  }

  void navigateToChatScreenUsingAccountId({
    required int peerAccountId,
    required bool isNew,
    required String screenName,
  }) async {
    try {
      Get.context?.loaderOverlay.show();
      final response = await sl<GetChatGroupByAccountIdUsecase>().call(
        GetChatGroupByAccountIdParams(accountId: peerAccountId),
      );
      final selfAccountId =
          Get.find<UserController>().userDetails.value.accountId ?? 0;

      if (response.error == null &&
          response.data != null &&
          selfAccountId != 0) {
        final chatGroup = response.data!;
        Get.to(
          () => ChatScreen(
            chatGroup: chatGroup,
            searchTerm: null,
            categoryCode: CategoryCode.GOSSIP,
            selfAccountId: selfAccountId,
            isNew: isNew,
            filter: ChatTabFilter.ALL,
            screenName: screenName,
          ),
        );
      } else {
        AlertService.showSnackBar(
          snackBarType: SnackBarType.Error,
          title: LocaleKeys.errorTitle.tr,
          subtitle: LocaleKeys.liveFailedToFetchChatGroup.tr,
        );
      }
    } catch (e) {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.errorTitle.tr,
        subtitle: LocaleKeys.liveFailedToFetchChatGroup.tr,
      );
    } finally {
      Get.context?.loaderOverlay.hide();
    }
  }
}
