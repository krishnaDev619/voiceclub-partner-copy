import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/account/meeting.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/meetings/widgets/meetings_card_widget.dart';
import 'package:voiceclub_partner/view/meetings/widgets/no_scheduled_meetings_widget.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';
import 'package:get/get.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> {
  final userController = Get.find<UserController>();
  List<Meeting> meetings = [];

  @override
  void initState() {
    super.initState();
    sl<AnalyticsService>().trackEvent("meetingScreen");
    meetings = userController.meetings;
  }

  Future<void> _refreshMeetings() async {
    await userController.getMeetingSchedule();
    setState(() {
      meetings = userController.meetings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: CustomAppBar(
        title: LocaleKeys.liveKamMeetings.tr,
        titleFontSize: FontSize.xL,
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshMeetings,
          child:
              meetings.isEmpty
                  ? NoScheduledMeetingsWidget()
                  : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: meetings.length,
                    itemBuilder: (context, index) {
                      return MeetingsCardWidget(meeting: meetings[index]);
                    },
                  ),
        ),
      ),
    );
  }
}
