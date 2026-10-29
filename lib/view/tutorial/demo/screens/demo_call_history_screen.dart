import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/call_logs/call_log.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoCallHistoryScreen extends StatefulWidget {
  final int userId;
  final String name;
  final String avatar;

  const DemoCallHistoryScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.avatar,
  });

  @override
  State<DemoCallHistoryScreen> createState() => _DemoCallHistoryScreenState();
}

class _DemoCallHistoryScreenState extends State<DemoCallHistoryScreen> {
  final logs = <CallLog>{};
  late Future<void> prepareFuture;

  @override
  void initState() {
    prepareFuture = getData();
    super.initState();
  }

  Icon getLogIcon(String callState) {
    IconData iconData = Icons.call_missed_rounded;
    Color iconColor = Colors.red;
    switch (callState.toUpperCase()) {
      case 'MISSED':
        iconData = Icons.call_missed_rounded;
        break;
      case 'ENDED':
        iconData = Icons.call_received_rounded;
        iconColor = Colors.green;
        break;
      case 'REJECTED':
        iconData = Icons.call_missed_rounded;
        break;
      default:
        iconData = Icons.call_received_rounded;
        break;
    }
    return Icon(iconData, size: 20.0, color: iconColor);
  }

  Widget _getChatDisplay() {
    return CustomProfilePicture(
      avatarURL: "",
      name: widget.name,
      backgroundColor: Get.theme.primaryColor,
    );
  }

  @override
  void dispose() {
    logs.clear();
    super.dispose();
  }

  Future<void> getData() async {
    logs.add(
      CallLog(
        id: 1,
        callAccepted: true,
        callAcceptedTime:
            DateTime.now()
                .subtract(const Duration(minutes: 40))
                .microsecondsSinceEpoch,
        callEnd: true,
        callEndTime:
            DateTime.now()
                .subtract(const Duration(minutes: 10))
                .microsecondsSinceEpoch,
        supplyName: LocaleKeys.demoUser.tr,
        createdAt:
            DateTime.now()
                .subtract(const Duration(minutes: 15))
                .toIso8601String(),
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String formattedDate = '';

    if (isSameDay(dateTime, today)) {
      formattedDate = LocaleKeys.demoToday.tr;
    } else if (isSameDay(dateTime, yesterday)) {
      formattedDate = LocaleKeys.demoYesterday.tr;
    } else if (now.difference(dateTime).inDays < 7) {
      formattedDate = DateFormat('EEEE').format(dateTime);
    } else if (dateTime.year == now.year) {
      formattedDate = DateFormat('E, dd MMM').format(dateTime);
    } else {
      formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    }

    final formattedTime = DateFormat('HH:mm').format(dateTime);

    return '$formattedDate $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Get.theme.primaryColor,
          statusBarIconBrightness: Brightness.light,
        ),
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        backgroundColor: Get.theme.primaryColor,
        title: Text(
          LocaleKeys.demoCallHistory.tr,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: prepareFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting ||
              logs.isNotEmpty) {
            return logs.isEmpty
                ? Center(child: Text(LocaleKeys.demoNoCallsYet.tr))
                : RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      logs.clear();
                    });
                    prepareFuture = getData();
                  },
                  child: ListView.separated(
                    itemCount: logs.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    separatorBuilder:
                        (context, index) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: Divider(height: 4.0),
                        ),
                    itemBuilder: (context, index) {
                      final log = logs.toList()[index];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            selected: true,
                            selectedColor: Colors.black,
                            dense: true,
                            leading: _getChatDisplay(),
                            title: Text(
                              widget.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: FontSize.L,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    getLogIcon(log.callState ?? ''),
                                    const SizedBox(width: 4.0),
                                    Text(
                                      formatDateTime(
                                        DateTime.parse(log.createdAt ?? ''),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: FontSize.M,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Visibility(
                              visible: (log.reason?.trim().isNotEmpty ?? false),
                              child: Container(
                                width: 108.0,
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        (log.callState == "ENDED")
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  log.message ?? '',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color:
                                        (log.callState == "ENDED")
                                            ? Colors.green
                                            : Colors.red,
                                    fontSize: FontSize.xS,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
