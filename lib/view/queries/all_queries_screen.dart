import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/queries/controller/queries_controller.dart';
import 'package:voiceclub_partner/view/queries/query_chat_screen.dart';
import 'package:voiceclub_partner/view/queries/widget/chat_query_card.dart';
import 'package:voiceclub_partner/view/queries/widget/queries_empty_state.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class AllQueriesScreen extends StatefulWidget {
  const AllQueriesScreen({super.key});

  @override
  State<AllQueriesScreen> createState() => _AllQueriesScreenState();
}

class _AllQueriesScreenState extends State<AllQueriesScreen> {
  final queriesController = Get.find<QueriesController>();
  final userController = Get.find<UserController>();
  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    queriesController.fetchAllQueries();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      queriesController.fetchMoreQueries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ApplicationColors.screenBackground,
      appBar: CustomAppBar(
        title: LocaleKeys.liveAllQueries.tr,
        centerTitle: true,
        titleFontSize: 16.0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            queriesController.fetchAllQueries();
            queriesController.fetchUnseenKamQueryChatMessageCount();
          },
          child: Obx(() {
            if (queriesController.isChatListLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (queriesController.queries.isEmpty) {
              return QueriesEmptyState(
                onAddQueryTap: () {
                  queriesController.navigateToAllQueryChatScreen(
                    source: "AllQueriesScreen",
                  );
                },
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    itemCount:
                        queriesController.queries.length +
                        (queriesController.isLoadingMoreQueries.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= queriesController.queries.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final query = queriesController.queries[index];
                      return GestureDetector(
                        onTap: () async {
                          sl<AnalyticsService>().trackEvent(
                            "partnerTicketOpen",
                            eventProperties: {
                              "ticketId":
                                  query.id?.toString().padLeft(6, '0') ?? '',
                              "issueCategory": query.category?.name ?? '',
                              "title": query.title ?? '',
                              "kamName": query.kamName ?? '',
                              "stage": userController.partnerStatus.value.name,
                            },
                          );
                          await queriesController.getDailyQueryRaisedCount();
                          await Get.to(
                            () => QueryChatScreen(
                              sessionId: query.sessionId ?? '',
                              querySessionStatus: query.status,
                              source: "AllQueriesScreen",
                            ),
                          );
                          if (query.kamMessageCount != null &&
                              query.kamMessageCount! > 0) {
                            queriesController.fetchAllQueries();
                            queriesController
                                .fetchUnseenKamQueryChatMessageCount();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ChatQueryCard(
                            title:
                                query.title != null && query.title!.isNotEmpty
                                    ? query.title!
                                    : LocaleKeys.liveGeneralQuery.tr,
                            date: query.createdAt ?? DateTime.now(),
                            status: query.status ?? QuerySessionStatus.ONGOING,
                            kamMessageCount: query.kamMessageCount ?? 0,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: CustomButton(
                    text: LocaleKeys.liveAddANewQuery.tr,
                    onTap: () {
                      queriesController.navigateToAllQueryChatScreen(
                        source: "AllQueriesScreen",
                      );
                    },
                    width: Get.width / 1.2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 16.0,
                    ),
                    color: const Color(0xFFEE6464),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
