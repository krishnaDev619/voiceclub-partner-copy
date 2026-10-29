import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoChatNotificationMessage extends StatelessWidget {
  const DemoChatNotificationMessage({
    super.key,
    required this.demand,
    required this.supply,
    required this.sentByMe,
    required this.time,
    required this.categoryCode,
  });

  final DateTime time;
  final ChatMember demand, supply;
  final bool sentByMe;
  final CategoryCode categoryCode;

  String getText() {
    String text = '';

    if (!sentByMe) {
      text = LocaleKeys.demoUserOnline.trParams({
        'name': supply.user?.name ?? '',
      });
    } else {
      text = LocaleKeys.demoYouSentNotification.trParams({
        'name': demand.user?.name ?? '',
      });
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6.0),
      margin: EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: MediaQuery.of(context).size.width * 0.05,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black,
              size: 18.0,
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  getText(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              ),
            ),
            Text(
              DateFormat.Hm().format(time),
              style: const TextStyle(
                height: 1.5,
                fontSize: FontSize.S,
                color: Color(0xFF999999),
                textBaseline: TextBaseline.alphabetic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
