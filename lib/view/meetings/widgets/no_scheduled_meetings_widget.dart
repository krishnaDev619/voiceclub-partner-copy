import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';

class NoScheduledMeetingsWidget extends StatelessWidget {
  const NoScheduledMeetingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 200,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(AssetConstants.noMeetings, height: 200, width: 200),
            const SizedBox(height: 30),
            Text(
              "No Scheduled Meetings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
