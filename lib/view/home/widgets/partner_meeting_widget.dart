import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/account/meeting.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class PartnerMeetingWidget extends StatelessWidget {
  const PartnerMeetingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return Obx(() {
      final meetings = userController.meetings;

      // Show widget if there are any meetings with valid Google Meet links that aren't ended
      final hasValidMeetings = meetings.any(
        (meeting) =>
            (meeting.googleMeetLink?.isNotEmpty ?? false) &&
            !meeting.isMeetingEnded,
      );

      if (!hasValidMeetings || meetings.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              spreadRadius: 0.4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              LocaleKeys.homeUpcomingMeetings.tr,
              style: TextStyle(fontSize: FontSize.xL, fontWeight: Weight.heavy),
            ),
            const SizedBox(height: 4.0),
            Text(
              LocaleKeys.homeClickBell.tr,
              style: TextStyle(fontSize: FontSize.M, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 8.0),
            // Meetings List
            ...meetings
                .where(
                  (meeting) =>
                      (meeting.googleMeetLink?.isNotEmpty ?? false) &&
                      !meeting.isMeetingEnded,
                )
                .map((meeting) => MeetingItem(meeting: meeting)),
          ],
        ),
      );
    });
  }
}

class MeetingItem extends StatefulWidget {
  final Meeting meeting;

  const MeetingItem({super.key, required this.meeting});

  @override
  State<MeetingItem> createState() => _MeetingItemState();
}

class _MeetingItemState extends State<MeetingItem> {
  bool? _isReminderSet;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReminderState();
  }

  Future<void> _loadReminderState() async {
    final userController = Get.find<UserController>();
    final isSet = await userController.isReminderScheduled(
      widget.meeting.id ?? 0,
    );
    if (mounted) {
      setState(() {
        _isReminderSet = isSet;
      });
    }
  }

  Future<void> _toggleReminder() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final userController = Get.find<UserController>();

    try {
      if (_isReminderSet == true) {
        await userController.cancelReminder(widget.meeting.id ?? 0);
        setState(() {
          _isReminderSet = false;
        });
      } else {
        await userController.scheduleReminder(widget.meeting);
        setState(() {
          _isReminderSet = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Row(
          children: [
            // Time slot
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.meeting.formattedTimingString,
                    style: const TextStyle(
                      fontSize: FontSize.L,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(
                    widget.meeting.getDateString,
                    style: const TextStyle(
                      fontSize: FontSize.S,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12.0),

            // Single Button - either Join Now or Remind
            if (widget.meeting.isMeetingOngoing)
              // Join Now button for ongoing meetings
              ElevatedButton(
                onPressed: () {
                  launchUrl(Uri.parse(widget.meeting.googleMeetLink!));
                  sl<AnalyticsService>().trackEvent(
                    "joinMeeting",
                    eventProperties: {
                      'meetingLink': widget.meeting.googleMeetLink,
                      'meetingId': widget.meeting.id,
                      'timing': widget.meeting.formattedTimingString,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE6464),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 24.5,
                  ),
                  elevation: 0,
                ),
                child: Text(
                  LocaleKeys.homeJoinNow.tr,
                  style: TextStyle(
                    fontSize: FontSize.M,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              // Remind button for future meetings
              _isReminderSet == null
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : OutlinedButton.icon(
                    onPressed: _isLoading ? null : _toggleReminder,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Icon(
                              _isReminderSet == true
                                  ? Icons.check_circle
                                  : Icons.notifications_outlined,
                              size: 18.0,
                              color:
                                  _isReminderSet == true
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFEE6464),
                            ),
                    label: Text(
                      _isReminderSet == true
                          ? LocaleKeys.homeScheduled.tr
                          : LocaleKeys.homeNotifyMe.tr,
                      style: TextStyle(
                        fontSize: FontSize.M,
                        color:
                            _isReminderSet == true
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEE6464),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color:
                            _isReminderSet == true
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEE6464),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(8.0),
                    ),
                  ),
          ],
        ),
      ],
    );
  }
}
