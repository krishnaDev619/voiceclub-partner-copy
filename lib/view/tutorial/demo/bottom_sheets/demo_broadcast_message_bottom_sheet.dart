import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/view/auth/widgets/cancel_alert.dart';
import 'package:voiceclub_partner/view/chat/widgets/chat_action_bottom_bar.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoSendBroadcastMessageBottomSheet extends StatefulWidget {
  final String filterCode;
  final Set<int> broadcastList;

  const DemoSendBroadcastMessageBottomSheet({
    super.key,
    required this.broadcastList,
    required this.filterCode,
  });

  @override
  State<DemoSendBroadcastMessageBottomSheet> createState() =>
      _DemoSendBroadcastMessageBottomSheetState();
}

class _DemoSendBroadcastMessageBottomSheetState
    extends State<DemoSendBroadcastMessageBottomSheet> {
  final _messageController = TextEditingController();
  bool _sending = false;
  bool _hasText = false;
  bool _generated = false;
  final _demoController = Get.find<DemoLandingController>();

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {
        _hasText = _messageController.text.isNotEmpty;
        if (_generated) {
          _generated = _messageController.text.isNotEmpty;
        }
      });
    });
  }

  String limitTo280Characters(String input) {
    const int maxLength = 280;

    if (input.length > maxLength) {
      return input.substring(0, maxLength);
    }

    return input;
  }

  @override
  void dispose() {
    _messageController.dispose();
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
    return PopScope(
      canPop: !_sending,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: !_sending,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(
                    Icons.close,
                    size: 28.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 24.0),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.only(
                    left: 8.0,
                    right: 8.0,
                    top: 8.0,
                    bottom: 8.0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1.0,
                      color: const Color(0xFFA9A9A9),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: 6,
                    readOnly: _sending,
                    autofocus: true,
                    maxLength: 280,
                    decoration: InputDecoration(
                      hintText: LocaleKeys.demoTypeMessage.tr,
                      contentPadding: EdgeInsets.fromLTRB(8.0, 0.0, 20.0, 0.0),
                      border: InputBorder.none,
                      counter: SizedBox.shrink(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (!_sending) {
                      if (_hasText) {
                        final message = _messageController.text.trim();
                        if (message.isNotEmpty) {
                          if (message.length < min) {
                            AlertService.showSnackBar(
                              snackBarType: SnackBarType.Error,
                              title: LocaleKeys.demoAlert.tr,
                              subtitle: LocaleKeys.demoMinMessageLength
                                  .trParams({'min': '$min'}),
                            );
                          } else if (message.length > max) {
                            AlertService.showSnackBar(
                              snackBarType: SnackBarType.Error,
                              title: LocaleKeys.demoAlert.tr,
                              subtitle: LocaleKeys.demoMaxMessageLength
                                  .trParams({'max': '$max'}),
                            );
                          } else {
                            bool? result = await Get.dialog(
                              CancelAlertDialog(
                                title: LocaleKeys.demoSendBroadcast.tr,
                                subtitle: LocaleKeys.demoSendBroadcastConfirm
                                    .trParams({
                                      'count': '${widget.broadcastList.length}',
                                    }),
                              ),
                            );
                            if (result ?? false) {
                              if (_demoController.selectedFilterOption.value ==
                                  "MID_USERS") {
                                _demoController.validateAction(
                                  TutorialDemoFeature.BROADCAST_MID_USER,
                                );
                              }
                              setState(() {
                                _sending = true;
                              });

                              Get.focusScope?.unfocus();
                              setState(() {
                                _sending = false;
                              });
                              Get.back(result: true);
                              AlertService.showSnackBar(
                                snackBarType: SnackBarType.Success,
                                title: LocaleKeys.demoBroadcastSent.tr,
                                subtitle: LocaleKeys.demoMessageSentToUsers.tr,
                              );
                            }
                          }
                        }
                      }
                    }
                  },
                  child: Container(
                    height: 48.0,
                    width: double.infinity,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      border: Border.all(color: Get.theme.primaryColor),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 6.0),
                      ],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child:
                        _sending
                            ? const SizedBox(
                              height: 24.0,
                              width: 24.0,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            )
                            : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  LocaleKeys.demoSendMessage.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: FontSize.L,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6.0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Transform.rotate(
                                      angle: 5.5,
                                      child: const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
