import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/core/services/notify_demand_service.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';

import 'package:voiceclub_partner/view/logs/logs_controller.dart';
import 'package:voiceclub_partner/view/partner_profile/widgets/block_bottom_sheet.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/home/home_labels.dart';
import 'package:voiceclub_partner/view/live_labels.dart';

final logsSearchController = TextEditingController();

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final controller = Get.find<LogsController>();
  late ScrollController _scrollController;
  int _currentPage = 1; // at first it will load only 30
  final _notificationService = NotifyDemandService();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  @override
  void initState() {
    sl<AnalyticsService>().trackEvent("partnerLogsScreen");
    _scrollController =
        ScrollController()..addListener(() {
          if (_scrollController.position.atEdge) {
            if (_scrollController.position.pixels == 0) {
            } else {
              setState(() {
                _currentPage++;
              });
              controller.fetchLogs(page: _currentPage);
            }
          }
        });
    super.initState();
  }

  Widget cardGradientContent({
    required LogType logType,
    required LogType selectedLog,
    required String value,
  }) {
    final isSelected = selectedLog == logType;
    return GestureDetector(
      onTap: () {
        sl<AnalyticsService>().trackEvent(
          "callFilter",
          eventProperties: {"option": logType.name, "optionNumber": value},
        );
        setState(() {
          _currentPage = 1;
        });
        controller.fetchLogs(page: _currentPage, logType: logType);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Get.theme.primaryColor
                  : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          LocaleKeys.demoLogCount.trParams({
            'type': liveLogLabel(logType),
            'value': value,
          }),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: LocaleKeys.liveCallLogs.tr,
        showBackButton: false,
      ),
      body: Obx(() {
        final logs = controller.logs;
        final logsResponse = controller.logsResponse.value;
        // Filter the logs based on the search query
        final filteredLogs =
            logs.where((log) {
              final searchTerm = logsSearchController.text.toLowerCase();
              final logName = log.name?.toLowerCase() ?? '';
              return logName.contains(searchTerm);
            }).toList();
        return (controller.isInit.value)
            ? RefreshIndicator(
              onRefresh: () async {
                await controller.fetchLogs();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: logsSearchController,
                        onChanged: (value) {
                          _debouncer.call(() {
                            setState(() {});
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: SizedBox(
                        height: 36.0,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          children: [
                            PopupMenuButton<OverviewFilter>(
                              onSelected: (value) {
                                if (value !=
                                    controller.selectedOverviewFilter.value) {
                                  controller.fetchLogs(
                                    page: 1,
                                    overviewFilter: value,
                                  );
                                }
                              },
                              position: PopupMenuPosition.under,
                              itemBuilder: (context) {
                                return OverviewFilter.values
                                    .map(
                                      (e) => PopupMenuItem<OverviewFilter>(
                                        value: e,
                                        child: Text(homeOverviewLabel(e)),
                                      ),
                                    )
                                    .toList();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8.0),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 14.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: Get.theme.primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      homeOverviewLabel(
                                        controller.selectedOverviewFilter.value,
                                      ),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Get.theme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 2.0),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 16.0,
                                      color: Get.theme.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            cardGradientContent(
                              logType: LogType.Missed,
                              selectedLog: controller.selectedLogType.value,
                              value: logsResponse.missedCall.toString(),
                            ),
                            cardGradientContent(
                              logType: LogType.Busy,
                              selectedLog: controller.selectedLogType.value,
                              value: logsResponse.busyCall.toString(),
                            ),
                            cardGradientContent(
                              logType: LogType.Offline,
                              selectedLog: controller.selectedLogType.value,
                              value: logsResponse.offline.toString(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Builder(
                      builder: (_) {
                        if (controller.isLoading.value) {
                          return Padding(
                            padding: EdgeInsets.only(top: Get.width / 2),
                            child: const Center(
                              child: SizedBox(
                                height: 32.0,
                                width: 32.0,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        } else {
                          if (filteredLogs.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.only(top: Get.width / 2),
                              child: Center(
                                child: Text(LocaleKeys.liveNoCallsFound.tr),
                              ),
                            );
                          } else {
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder:
                                  (_, _) => const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Divider(height: 6.0),
                                  ),
                              itemCount: filteredLogs.length,
                              itemBuilder: (context, index) {
                                final log = filteredLogs[index];
                                String name = log.name ?? '';
                                if (name.isEmpty) {
                                  return const SizedBox.shrink();
                                } else {
                                  return ListTile(
                                    onTap: () {
                                      if (Get.isRegistered<
                                        ChatOverviewController
                                      >()) {
                                        Get.find<ChatOverviewController>()
                                            .navigateToChatScreenUsingAccountId(
                                              peerAccountId: log.accountId ?? 0,
                                              isNew: false,
                                              screenName: "LogsScreen",
                                            );
                                      }
                                    },
                                    selected: true,
                                    selectedColor: Colors.black,
                                    minLeadingWidth: 36.0,
                                    dense: true,
                                    leading: CustomProfilePicture(
                                      name: (name[0]).toUpperCase(),
                                      avatarURL: "",
                                      backgroundColor: Get.theme.primaryColor,
                                    ),
                                    title: Text(
                                      '$name${(log.callCount ?? 0) > 0 ? ' (${log.callCount})' : ''}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    subtitle: Text(
                                      DateFormat(
                                        'hh:mm aaa MMM dd, yyyy',
                                      ).format(
                                        DateTime.parse(
                                          log.lastCalledAt ?? '',
                                        ).toLocal(),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    trailing: Builder(
                                      builder: (context) {
                                        final isBlocked =
                                            log.isBlocked ?? false;
                                        if (isBlocked) {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8.0,
                                                ),
                                                child: OutlinedButton(
                                                  style: ButtonStyle(
                                                    padding:
                                                        WidgetStateProperty.all(
                                                          const EdgeInsets.symmetric(
                                                            vertical: 2.0,
                                                            horizontal: 18.0,
                                                          ),
                                                        ),
                                                    side:
                                                        WidgetStateProperty.all(
                                                          const BorderSide(
                                                            color: Colors.grey,
                                                            width: 1.0,
                                                          ),
                                                        ),
                                                  ),
                                                  onPressed: () {},
                                                  child: const Text(
                                                    'Blocked',
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.notifications_active,
                                                color: Colors.grey,
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.only(
                                                  left: 4.0,
                                                ),
                                                child: Icon(
                                                  Icons.more_vert,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          );
                                        } else {
                                          return Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Disabled(
                                                disabled:
                                                    Get.find<UserController>()
                                                        .currentStage
                                                        .isLessThan(
                                                          TutorialStage.S4,
                                                        ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    if (log.uid != null) {
                                                      _notificationService
                                                          .sendNotificationToDemand(
                                                            logId: log.logId,
                                                            demandUid:
                                                                log.uid ?? 0,
                                                            isAudio: false,
                                                            userName: name,
                                                            screenName:
                                                                'PartnerLogsScreen',
                                                          );
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6.0,
                                                          ),
                                                    ),
                                                    child: FutureBuilder(
                                                      future: _notificationService
                                                          .isAllowedToSendNormalNotification(
                                                            demandUserId:
                                                                log.uid ?? 0,
                                                          ),
                                                      builder: (
                                                        context,
                                                        snapshot,
                                                      ) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .done) {
                                                          bool isAllowed =
                                                              snapshot.data ??
                                                              false;
                                                          return Icon(
                                                            Icons
                                                                .notifications_active,
                                                            color:
                                                                !isAllowed
                                                                    ? Colors
                                                                        .grey
                                                                    : ApplicationColors
                                                                        .primaryRed,
                                                          );
                                                        } else {
                                                          return const Icon(
                                                            Icons
                                                                .notifications_active,
                                                            color:
                                                                ApplicationColors
                                                                    .primaryRed,
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              PopupMenuButton(
                                                position:
                                                    PopupMenuPosition.under,
                                                padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  right: 0.0,
                                                ),
                                                elevation: 8,
                                                onSelected: (_) async {
                                                  bool isBlocked =
                                                      log.isBlocked ?? false;
                                                  if (isBlocked) {
                                                    AlertService.showSnackBar(
                                                      snackBarType:
                                                          SnackBarType.Warning,
                                                      title:
                                                          LocaleKeys
                                                              .liveBlocked
                                                              .tr,
                                                      subtitle:
                                                          '$name is already blocked!',
                                                    );
                                                  } else {
                                                    sl<AnalyticsService>()
                                                        .trackEvent(
                                                          'blockInitiatePartner',
                                                          eventProperties: {
                                                            'demandName': name,
                                                            'demandUid':
                                                                log.uid,
                                                          },
                                                        );
                                                    Get.bottomSheet(
                                                      BlockProfileBottomSheet(
                                                        isReport: false,
                                                        name: name,
                                                        avatar:
                                                            AvatarService.getRandomAvatarUrl(),
                                                        accountId:
                                                            log.accountId ?? 0,
                                                      ),
                                                      isScrollControlled: true,
                                                      isDismissible: true,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16.0,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                itemBuilder: (BuildContext bc) {
                                                  return const [
                                                    PopupMenuItem(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8.0,
                                                            vertical: 6.0,
                                                          ),
                                                      height: 18,
                                                      textStyle: TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                      value: 'Block',
                                                      child: Text(
                                                        "Block User",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ];
                                                },
                                                child: const Icon(
                                                  Icons.more_vert,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                  );
                                }
                              },
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            )
            : Center(child: Text(LocaleKeys.homeNoData.tr));
      }),
    );
  }
}
