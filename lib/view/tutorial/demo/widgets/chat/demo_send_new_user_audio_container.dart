import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_group.dart';
import 'package:voiceclub_partner/data/models/chat/member.dart';
import 'package:voiceclub_partner/data/models/chat/pending_audio.dart';
import 'package:voiceclub_partner/data/models/notifications/user_data.dart';
import 'package:voiceclub_partner/modules/controller/user_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/screens/demo_chat_screen.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class DemoSendNewUserAudioContainer extends StatefulWidget {
  final PendingAudio pendingAudio;

  const DemoSendNewUserAudioContainer({super.key, required this.pendingAudio});

  @override
  State<DemoSendNewUserAudioContainer> createState() =>
      _DemoSendNewUserAudioContainerState();
}

class _DemoSendNewUserAudioContainerState
    extends State<DemoSendNewUserAudioContainer>
    with AutomaticKeepAliveClientMixin {
  late Stream<int> countdownStream;

  @override
  void initState() {
    countdownStream = countdownStreamController(
      widget.pendingAudio.timeLeftInSecs ?? 0,
    );
    super.initState();
  }

  Stream<int> countdownStreamController(int remainingSeconds) {
    final controller = StreamController<int>();

    Stream.periodic(const Duration(seconds: 1), (count) {
          return remainingSeconds - count - 1;
        })
        .takeWhile((value) => value >= 0)
        .listen(
          (value) {
            // Trigger a rebuild when the countdown updates
            controller.add(value);
          },
          onDone: () {},
          onError: controller.addError,
          cancelOnError: true,
        );

    return controller.stream;
  }

  String formatTime(int seconds) {
    final hours = (seconds ~/ 3600);
    final minutes = ((seconds % 3600) ~/ 60);
    final remainingSeconds = seconds % 60;

    final formattedHours = hours.toString().padLeft(2, '0');
    final formattedMinutes = minutes.toString().padLeft(2, '0');
    final formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

    return '$formattedHours:$formattedMinutes:$formattedSeconds';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        Get.to(
          () => DemoChatScreen(
            isNew: true,
            chatGroup: ChatGroup(
              id: 2,
              title: 'Paraag',
              tier: ChatTier.PRO,
              members: [
                ChatMember(
                  accountId: 342233,
                  user: UserDataModel(id: 324256, name: 'Paraag'),
                ),
                ChatMember(
                  accountId: Get.find<UserController>().accountId,
                  user: Get.find<UserController>().userDetails.value.user,
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        height: 120.0,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Get.theme.primaryColor, width: 1.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  SizedBox(
                    height: 60.0,
                    width: 54.0,
                    child: Stack(
                      children: [
                        Container(
                          height: 54.0,
                          width: 54.0,
                          padding: const EdgeInsets.all(2.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFA9CF54),
                          ),
                          child: SvgPicture.asset(AssetConstants.avatarIcon),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 54.0,
                            height: 16.0,
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              color: Get.theme.primaryColor,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: FittedBox(
                              child: Text(
                                LocaleKeys.demoNewUser.tr,
                                style: TextStyle(
                                  fontSize: FontSize.xS,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          LocaleKeys.demoSendAudioTo.trParams({
                            'name': widget.pendingAudio.user?.name ?? '',
                          }),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: FontSize.xL,
                            fontWeight: FontWeight.bold,
                            color: Get.theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        if ((widget.pendingAudio.amount ?? 0) > 1)
                          Text(
                            LocaleKeys.demoAndGetAmount.trParams({
                              'amount':
                                  widget.pendingAudio.amount?.toStringAsFixed(
                                    2,
                                  ) ??
                                  '',
                            }),
                            style: const TextStyle(fontSize: FontSize.M),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Get.theme.primaryColor,
                    ),
                    child: Transform.translate(
                      offset: const Offset(2.0, 0.0),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                decoration: BoxDecoration(
                  color: Get.theme.primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                ),
                child: Center(
                  child: StreamBuilder<int>(
                    stream: countdownStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          LocaleKeys.demoTimeLeft.trParams({
                            'time': formatTime(snapshot.data ?? 0),
                          }),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: FontSize.M,
                          ),
                        );
                      } else {
                        return Text(
                          LocaleKeys.demoTimeLeftZero.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: FontSize.M,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
