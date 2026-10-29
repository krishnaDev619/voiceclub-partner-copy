import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/widgets/chat/demo_broadcast_action_bottom_bar.dart';
import 'package:voiceclub_partner/view/widgets/custom_app_bar.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoBroadcastListView extends StatefulWidget {
  const DemoBroadcastListView({super.key});

  @override
  State<DemoBroadcastListView> createState() => _DemoBroadcastListViewState();
}

class _DemoBroadcastListViewState extends State<DemoBroadcastListView> {
  final _demoController = Get.find<DemoLandingController>();
  final broadcastList = <int>{};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    broadcastList.clear();
    _selectAll = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chatList = _demoController.matchingFilteredGroups.toList();
      return Scaffold(
        appBar: CustomAppBar(
          title: LocaleKeys.demoBroadcastTitle.trParams({
            'name': _demoController.selectedChatFilter.value.name ?? '',
          }),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Text(
                        LocaleKeys.demoSelectedCount.trParams({
                          'count': '${broadcastList.length}',
                        }),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    key: const Key("SelectAll"),
                    title: Text(LocaleKeys.demoSelectAllUsers.tr),
                    trailing: Checkbox(
                      key: const Key("checkboxSelectAll"),
                      value: _selectAll,
                      onChanged: ((value) {
                        broadcastList.clear();
                        if (value ?? false) {
                          var list = chatList;
                          if (chatList.length > 20) {
                            list =
                                chatList
                                    .where((chatGroup) => chatGroup.id != null)
                                    .toList();
                            if (list.length > 20) {
                              list = list.sublist(0, 20);
                            }
                          }
                          for (var chatGroup in list) {
                            if (chatGroup.id != null) {
                              broadcastList.add(chatGroup.id!);
                            }
                          }
                          setState(() {
                            _selectAll = true;
                          });
                        } else {
                          setState(() {
                            _selectAll = false;
                          });
                        }
                      }),
                    ),
                  ),
                  const Divider(height: 0.0, indent: 24.0, endIndent: 24.0),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: chatList.length,
                      padding: const EdgeInsets.only(bottom: 100.0),
                      separatorBuilder:
                          (context, index) => const Divider(
                            height: 4.0,
                            indent: 24.0,
                            endIndent: 24.0,
                          ),
                      itemBuilder: (context, index) {
                        final filterGroup = chatList[index];
                        bool enabled = filterGroup.id != null;
                        return ListTile(
                          key: Key((filterGroup.id).toString()),
                          leading: CustomProfilePicture(
                            avatarURL: "",
                            name: filterGroup.title,
                            backgroundColor:
                                enabled
                                    ? Get.theme.primaryColor
                                    : Colors.grey.shade300,
                          ),
                          title: Text(
                            (filterGroup.title ?? ''),
                            maxLines: 1,
                            style: TextStyle(
                              color: enabled ? Colors.black : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Visibility(
                            visible: enabled,
                            replacement: Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: Text(
                                LocaleKeys.demoSent.tr,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: FontSize.M,
                                ),
                              ),
                            ),
                            child: Visibility(
                              visible:
                                  (broadcastList.length < 20 ||
                                      broadcastList.contains(filterGroup.id)),
                              child: Checkbox(
                                key: Key("checkbox${filterGroup.id}"),
                                value: broadcastList.contains(filterGroup.id),
                                onChanged: ((value) {
                                  if (enabled) {
                                    if (value ?? false) {
                                      if (broadcastList.length < 20) {
                                        broadcastList.add(filterGroup.id!);
                                        if (broadcastList.length == 20) {
                                          _selectAll = true;
                                        }
                                      }
                                    } else {
                                      broadcastList.remove(filterGroup.id);
                                      if (_selectAll) {
                                        _selectAll = false;
                                      }
                                    }
                                    setState(() {});
                                  }
                                }),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: broadcastList.isNotEmpty,
                child: const Align(
                  alignment: Alignment.bottomCenter,
                  child: DemoBroadcastActionBottomBar(),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
