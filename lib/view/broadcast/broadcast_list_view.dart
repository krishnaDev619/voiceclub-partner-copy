import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/modules/controller/broadcast_controller.dart';
import 'package:voiceclub_partner/view/broadcast/widgets/broadcast_action_bottom_bar.dart';
import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class BroadcastListView extends StatefulWidget {
  final TextEditingController searchController;

  const BroadcastListView({super.key, required this.searchController});

  @override
  State<BroadcastListView> createState() => _BroadcastListViewState();
}

class _BroadcastListViewState extends State<BroadcastListView> {
  int _currentPage = 1; // at first it will load only 30
  late ScrollController _scrollController;
  final controller = Get.find<BroadcastController>();
  bool _selectAll = false;

  @override
  void initState() {
    _scrollController =
        ScrollController()..addListener(() {
          if (_scrollController.position.atEdge) {
            if (_scrollController.position.pixels == 0) {
            } else {
              if (_currentPage <= controller.totalFilteredPages.value) {
                setState(() {
                  _currentPage++;
                });
                fetchData();
              }
            }
          }
        });
    super.initState();
  }

  void fetchData() {
    String query = widget.searchController.text;
    if (query.isNotEmpty) {
    } else {
      controller.fetchFilteredChats(page: _currentPage);
    }
  }

  @override
  void dispose() {
    _selectAll = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final chatList = controller.matchingFilteredGroups.toList();
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      } else {
        return Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  child: Text(
                    '${controller.broadcastList.length}/20 selected',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  key: const Key("SelectAll"),
                  title: Text(LocaleKeys.liveSelectAllUsers.tr),
                  trailing: Checkbox(
                    key: const Key("checkboxSelectAll"),
                    value: _selectAll,
                    onChanged: ((value) {
                      controller.broadcastList.clear();
                      if (value ?? false) {
                        var list = chatList;
                        if (chatList.length > 20) {
                          list =
                              chatList
                                  .where(
                                    (chatGroup) =>
                                        chatGroup.id != null &&
                                        !controller.alreadyBroadcastIDs
                                            .contains(chatGroup.id),
                                  )
                                  .toList();
                          if (list.length > 20) {
                            list = list.sublist(0, 20);
                          }
                        }
                        for (var chatGroup in list) {
                          if (chatGroup.id != null &&
                              !controller.alreadyBroadcastIDs.contains(
                                chatGroup.id,
                              )) {
                            controller.broadcastList.add(chatGroup.id!);
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
                    controller: _scrollController,
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
                      bool enabled =
                          filterGroup.id != null &&
                          !controller.alreadyBroadcastIDs.contains(
                            filterGroup.id,
                          );
                      final tile = ListTile(
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
                            padding: EdgeInsets.only(right: 16.0),
                            child: Text(
                              LocaleKeys.liveSent.tr,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: FontSize.M,
                              ),
                            ),
                          ),
                          child: Visibility(
                            visible:
                                (controller.broadcastList.length < 20 ||
                                    controller.broadcastList.contains(
                                      filterGroup.id,
                                    )),
                            child: Checkbox(
                              key: Key("checkbox${filterGroup.id}"),
                              value: controller.broadcastList.contains(
                                filterGroup.id,
                              ),
                              onChanged: ((value) {
                                if (enabled) {
                                  if (value ?? false) {
                                    if (controller.broadcastList.length < 20) {
                                      controller.broadcastList.add(
                                        filterGroup.id!,
                                      );
                                      if (controller.broadcastList.length ==
                                          20) {
                                        _selectAll = true;
                                      }
                                    }
                                  } else {
                                    controller.broadcastList.remove(
                                      filterGroup.id,
                                    );
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
                      return tile;
                    },
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Visibility(
                visible: controller.broadcastList.isNotEmpty,
                child: const BroadcastActionBottomBar(),
              ),
            ),
          ],
        );
      }
    });
  }
}
