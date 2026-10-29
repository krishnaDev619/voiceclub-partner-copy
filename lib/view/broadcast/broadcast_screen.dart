import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:voiceclub_partner/modules/controller/broadcast_controller.dart';
import 'package:voiceclub_partner/view/broadcast/broadcast_list_view.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

final broadcastSearchController = TextEditingController();

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final controller = Get.find<BroadcastController>();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: LocaleKeys.liveBroadcastTitle.trParams({
          'name': controller.broadcastFilter.filterName,
        }),
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextField(
                controller: broadcastSearchController,
                onTapOutside: (_) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                onChanged: (_) {
                  _debouncer.call(() {
                    controller.searchFilteredChats(
                      broadcastSearchController.text,
                    );
                  });
                },
                onSubmitted: (query) {
                  Get.focusScope?.unfocus();
                },
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: LocaleKeys.liveSearch.tr,
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
            Expanded(
              child: BroadcastListView(
                searchController: broadcastSearchController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
