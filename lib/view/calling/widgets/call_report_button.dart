import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/view/widgets/rounded_button.dart';

class CallReportButton extends StatelessWidget {
  final void Function(String) onReport;
  final double size;
  const CallReportButton({
    super.key,
    required this.onReport,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      size: size,
      press: () {
        Get.bottomSheet(
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 100,
                        height: 6.0,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0.0),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    var ds =
                        [
                          {
                            "english": "Asking for Personal Information",
                            "hindi": "Apka personal information maang raha hai",
                          },
                          {
                            "english": "Sexual Conversation",
                            "hindi": "Galat/Vulgar baat kar raha hai",
                          },
                          {
                            "english": "Harassing on Call",
                            "hindi": "Call par pareshan kar raha hai",
                          },
                        ][index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 40,
                          height: 40,
                          child: const Center(
                            child: Icon(Icons.report, color: Colors.red),
                          ),
                        ),
                        title: Text(
                          ds["english"] ?? '',
                          style: const TextStyle(fontSize: 11),
                        ),
                        subtitle: Text(
                          ds["hindi"] ?? '',
                          style: const TextStyle(fontSize: 11),
                        ),
                        onTap: () async {
                          try {
                            final blockMessage = jsonEncode({
                              "type": "report",
                              "reason": ds["english"] ?? '',
                            });
                            onReport(blockMessage);
                          } catch (_) {
                          } finally {
                            Get.back();
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        );
      },
      color: Colors.white.withValues(alpha: 0.1),
      iconColor: Colors.white,
      iconSrc: AssetConstants.voicemailIcon,
      iconData: Icons.block,
    );
  }
}
