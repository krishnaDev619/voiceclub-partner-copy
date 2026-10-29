import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/account/meeting.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';

class MeetingsCardWidget extends StatefulWidget {
  final Meeting meeting;

  const MeetingsCardWidget({super.key, required this.meeting});

  @override
  State<MeetingsCardWidget> createState() => _MeetingsCardWidgetState();
}

class _MeetingsCardWidgetState extends State<MeetingsCardWidget> {
  bool? _isReminderSet;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (!widget.meeting.isMeetingOngoing) {
      _loadReminderState();
    }
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
        if (mounted) {
          setState(() {
            _isReminderSet = false;
          });
        }
      } else {
        await userController.scheduleReminder(widget.meeting);
        if (mounted) {
          setState(() {
            _isReminderSet = true;
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleJoinMeeting() async {
    final link = widget.meeting.googleMeetLink;
    if (link != null && link.isNotEmpty) {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        sl<AnalyticsService>().trackEvent(
          "joinMeeting",
          eventProperties: {
            'meetingLink': link,
            'meetingId': widget.meeting.id,
            'timing': widget.meeting.formattedTimingString,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.meeting.getDateString,
                style: const TextStyle(
                  fontSize: FontSize.M,
                  color: Color(0xFF9E9E9E), // Light grey
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0E0), // Light pink
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  widget.meeting.formattedTimingString,
                  style: const TextStyle(
                    fontSize: FontSize.S,
                    color: Color(0xFF9E9E9E), // Light grey
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Text(
            widget.meeting.title ?? "Meeting Title",
            style: const TextStyle(
              fontSize: FontSize.xL,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            width: double.infinity,
            child:
                widget.meeting.isMeetingOngoing
                    ? // Join Now button for ongoing meetings
                    ElevatedButton(
                      onPressed: _handleJoinMeeting,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ApplicationColors.primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Join Now',
                        style: TextStyle(
                          fontSize: FontSize.L,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                    : // Set Reminder button for future meetings
                    _isReminderSet == null
                    ? const SizedBox(
                      height: 48.0,
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                    : ElevatedButton.icon(
                      onPressed: _isLoading ? null : _toggleReminder,
                      icon:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: ApplicationColors.primaryRed,
                                ),
                              )
                              : Icon(
                                _isReminderSet == true
                                    ? Icons.check_circle
                                    : Icons.notifications_outlined,
                                size: 20.0,
                              ),
                      label: Text(
                        _isReminderSet == true ? 'Scheduled' : 'Set Reminder',
                        style: const TextStyle(
                          fontSize: FontSize.L,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: ApplicationColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: ApplicationColors.primaryRed),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        elevation: 0,
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
