import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';

class MetricsInfoSection extends StatelessWidget {
  final String? lastUpdatedTime;

  const MetricsInfoSection({super.key, this.lastUpdatedTime});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 5.0),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_outline,
                size: 14.0,
                color: Color(0xFF8F8F8F),
              ),
              const SizedBox(width: 6.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Your metrics will update every morning at 3.30 AM.",
                    style: TextStyle(
                      color: Color(0xFF8F8F8F),
                      fontSize: FontSize.M,
                    ),
                  ),
                  if (lastUpdatedTime != null)
                    Text(
                      "Last updated at: ${DateFormat.Hm().format(DateTime.parse(lastUpdatedTime ?? '').toLocal())}",
                      style: const TextStyle(
                        color: Color(0xFF8F8F8F),
                        fontSize: FontSize.M,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
