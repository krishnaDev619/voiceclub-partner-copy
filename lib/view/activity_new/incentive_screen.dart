import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/modules/controller/rewards_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_conversion_controller.dart';
import 'package:voiceclub_partner/view/activity_new/widgets/new_user_tile.dart';
import 'package:voiceclub_partner/view/rewards/daily_rewards/widgets/rewards_progress_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class IncentiveListing extends StatefulWidget {
  const IncentiveListing({super.key});

  @override
  State<IncentiveListing> createState() => _IncentiveListingState();
}

class _IncentiveListingState extends State<IncentiveListing> {
  final TextEditingController _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));
  late ScrollController _scrollController;
  late UserConversionController userCriteriaController;
  int _currentPage = 1;
  final rewardsController = Get.find<RewardsController>();

  @override
  void initState() {
    userCriteriaController = Get.put(
      UserConversionController(isConverted: false),
    );
    _scrollController =
        ScrollController()..addListener(() {
          if (_scrollController.position.atEdge) {
            if (_scrollController.position.pixels != 0) {
              if (_currentPage <= userCriteriaController.totalPages.value) {
                setState(() {
                  _currentPage++;
                });
                fetchData();
              }
            }
          }
        });
    sl<AnalyticsService>().trackEvent("incentiveScreen");
    super.initState();
  }

  void fetchData() {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      userCriteriaController.getCriteriaUsers(page: _currentPage, query: query);
    } else {
      userCriteriaController.getCriteriaUsers(page: _currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.live30MinReward.tr,
          style: const TextStyle(
            fontWeight: Weight.heavy,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.1,
      ),
      body: SafeArea(
        child: GetBuilder<UserConversionController>(
          builder: (controller) {
            return SizedBox(
              height: Get.height,
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _currentPage = 1;
                  });
                  fetchData();
                  rewardsController.fetchRewardsStats();
                  Get.find<UserController>().getOnlineDuration();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Progress bar section
                      Obx(() {
                        if (rewardsController
                                .rewardsStats
                                .value
                                ?.incentiveCalls !=
                            null) {
                          return RewardsProgressBar(
                            rewards:
                                rewardsController
                                    .rewardsStats
                                    .value!
                                    .incentiveCalls!,
                            type: RewardsProgressBarType.incentive,
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        height: 54.0,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            _debouncer.call(() {
                              controller.getCriteriaUsers(
                                page: 1,
                                query: _searchController.text,
                              );
                            });
                          },
                          onTapOutside: (_) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          decoration: InputDecoration(
                            hintText: LocaleKeys.liveSearch.tr,
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA2E479).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          children: [
                            const Text("🤑", style: TextStyle(fontSize: 16.0)),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Text(
                                LocaleKeys.liveCall30Min.tr,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Builder(
                        builder: (_) {
                          if (controller.criteriaUsersList.isNotEmpty) {
                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.criteriaUsersList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return NewUserTileWidget(
                                  user:
                                      controller.criteriaUsersList
                                          .toList()[index],
                                  cutoffSeconds: controller.cutoff.value,
                                  screenName: "IncentiveScreen",
                                );
                              },
                            );
                          } else {
                            if (controller.isLoading.value) {
                              return Padding(
                                padding: EdgeInsets.only(top: Get.height * 0.3),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.only(top: Get.height * 0.3),
                                child: Center(
                                  child: Text(LocaleKeys.liveNoUsersFound.tr),
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
