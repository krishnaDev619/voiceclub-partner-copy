// ignore_for_file: avoid_unnecessary_containers

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';
import 'package:voiceclub_partner/data/models/chat/chat_filter.dart';
import 'package:voiceclub_partner/modules/bindings/broadcast_binding.dart';
import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
import 'package:voiceclub_partner/view/broadcast/broadcast_screen.dart';

class ChatFilterBottomSheet extends StatefulWidget {
  const ChatFilterBottomSheet({super.key});

  @override
  State<ChatFilterBottomSheet> createState() => _ChatFilterBottomSheetState();
}

class _ChatFilterBottomSheetState extends State<ChatFilterBottomSheet> {
  void _goBack() {
    Get.back();
  }

  Future<void> _onFilterListTileTap(ChatFilter filter) async {
    Get.back();
    Get.to(
      () => const BroadcastScreen(),
      duration: Duration.zero,
      binding: BroadcastBinding(broadcastFilter: filter),
    );
  }

  Widget _buildContent({required bool blockClose}) {
    final chatOverviewController = Get.find<ChatOverviewController>();

    return SafeArea(
      child: Obx(() {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!blockClose)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                  child: GestureDetector(
                    onTap: _goBack,
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.only(top: 20.0, bottom: 24.0),
              width: MediaQuery.of(context).size.width,
              decoration: const ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20.0, bottom: 8.0),
                      child: Text(
                        'Select chat group filter',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: FontSize.xL,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  for (final filter in chatOverviewController.filterOptions)
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      onTap: () => _onFilterListTileTap(filter),
                      leading: CircleAvatar(
                        backgroundImage: FastCachedImageProvider(
                          filter.icon ?? '',
                        ),
                      ),
                      title: Text(
                        filter.name ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        filter.description ?? '',
                        style: TextStyle(
                          fontSize: FontSize.M,
                          color: const Color(
                            0xFF3D3D3D,
                          ).withValues(alpha: 0.75),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    sl<AnalyticsService>().trackEvent(
      'partnerBottomSheetOpen',
      eventProperties: {'bottomSheetType': 'BroadcastFilterBottomSheet'},
    );

    return _buildContent(blockClose: false);
  }
}
