import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/services/avatar_service.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/view/tutorial/demo/bottom_sheets/demo_block_profile_bottom_sheet.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/core/disabled_widget.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:voiceclub_partner/view/tutorial/demo/demo_labels.dart';

class DemoLogsScreen extends StatefulWidget {
  const DemoLogsScreen({super.key});

  @override
  State<DemoLogsScreen> createState() => _DemoLogsScreenState();
}

class _DemoLogsScreenState extends State<DemoLogsScreen> {
  final controller = Get.find<DemoLandingController>();

  @override
  void initState() {
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
        controller.changeSelectedLogType(logType);
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
            'type': demoLogLabel(logType),
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
        title: LocaleKeys.demoCallLogs.tr,
        showBackButton: false,
      ),
      body: SafeArea(
        child: Obx(() {
          final logs = controller.logs;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: LocaleKeys.demoSearch.tr,
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
                            controller.changeSelectedOverviewFilter(value);
                          },
                          position: PopupMenuPosition.under,
                          itemBuilder: (context) {
                            return OverviewFilter.values
                                .map(
                                  (e) => PopupMenuItem<OverviewFilter>(
                                    value: e,
                                    child: Text(demoOverviewLabel(e)),
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
                              border: Border.all(color: Get.theme.primaryColor),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  demoOverviewLabel(
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
                          value: "3",
                        ),
                        cardGradientContent(
                          logType: LogType.Busy,
                          selectedLog: controller.selectedLogType.value,
                          value: "3",
                        ),
                        cardGradientContent(
                          logType: LogType.Offline,
                          selectedLog: controller.selectedLogType.value,
                          value: "3",
                        ),
                      ],
                    ),
                  ),
                ),
                Builder(
                  builder: (_) {
                    if (logs.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.only(top: Get.width / 2),
                        child: Center(
                          child: Text(LocaleKeys.demoNoCallsFound.tr),
                        ),
                      );
                    } else {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder:
                            (_, _) => const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Divider(height: 6.0),
                            ),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs.toList()[index];
                          String name = log.name ?? '';
                          if (name.isEmpty) {
                            return const SizedBox.shrink();
                          } else {
                            return ListTile(
                              onTap: () {},
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
                                DateFormat('hh:mm aaa MMM dd, yyyy').format(
                                  DateTime.parse(
                                    log.lastCalledAt ?? '',
                                  ).toLocal(),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: Disabled(
                                disabled: Get.find<DemoLandingController>()
                                    .currentStage
                                    .isLessThan(TutorialStage.S4),
                                child: Builder(
                                  builder: (context) {
                                    final isBlocked = controller.blockedUsers
                                        .any(
                                          (element) =>
                                              element.blockedAccountId ==
                                              log.accountId,
                                        );
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
                                                padding: WidgetStateProperty.all(
                                                  const EdgeInsets.symmetric(
                                                    vertical: 2.0,
                                                    horizontal: 18.0,
                                                  ),
                                                ),
                                                side: WidgetStateProperty.all(
                                                  const BorderSide(
                                                    color: Colors.grey,
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {},
                                              child: Text(
                                                LocaleKeys.demoBlocked.tr,
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.notifications_active,
                                            color: Colors.grey,
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(left: 4.0),
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
                                          GestureDetector(
                                            onTap: () {
                                              AlertService.showSnackBar(
                                                snackBarType:
                                                    SnackBarType.Success,
                                                title:
                                                    LocaleKeys.demoSuccess.tr,
                                                subtitle:
                                                    LocaleKeys.demoAudioSent.tr,
                                              );
                                              controller.validateAction(
                                                TutorialDemoFeature
                                                    .CHAT_NOTIFICATION,
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6.0),
                                              ),
                                              child: const Icon(
                                                Icons.notifications_active,
                                                color:
                                                    ApplicationColors
                                                        .primaryRed,
                                              ),
                                            ),
                                          ),
                                          PopupMenuButton(
                                            position: PopupMenuPosition.under,
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                              right: 0.0,
                                            ),
                                            elevation: 8,
                                            onSelected: (_) async {
                                              if (isBlocked) {
                                                AlertService.showSnackBar(
                                                  snackBarType:
                                                      SnackBarType.Warning,
                                                  title:
                                                      LocaleKeys.demoBlocked.tr,
                                                  subtitle: LocaleKeys
                                                      .demoAlreadyBlocked
                                                      .trParams({'name': name}),
                                                );
                                              } else {
                                                Get.bottomSheet(
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10.0,
                                                        ),
                                                    child: DemoBlockProfileBottomSheet(
                                                      name: name,
                                                      avatar:
                                                          AvatarService.getRandomAvatarUrl(),
                                                      userData: UserDataModel(
                                                        id: log.accountId,
                                                        name: name,
                                                      ),
                                                      isChat: false,
                                                    ),
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
                                              return [
                                                PopupMenuItem(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                    vertical: 6.0,
                                                  ),
                                                  height: 18,
                                                  textStyle: TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                  value: 'Block',
                                                  child: Text(
                                                    LocaleKeys.demoBlockUser.tr,
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
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
