// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:voiceclub_partner/core/constants/enums.dart';
// import 'package:voiceclub_partner/core/constants/ui_constants.dart';
// import 'package:voiceclub_partner/core/injection_container.dart';
// import 'package:voiceclub_partner/core/services/analytics_service.dart';
// import 'package:voiceclub_partner/core/services/avatar_service.dart';
// import 'package:voiceclub_partner/data/models/supply_app/notifications/user_data.dart';
// import 'package:voiceclub_partner/modules/controller/chat_subscription_controller.dart';
// import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/subscription_features_bottom_sheet.dart';
// import 'package:voiceclub_partner/view/chat/widgets/chat_locked_time_bar.dart';
// import 'package:voiceclub_partner/view/chat/widgets/subscription_button.dart';

// class UnlockChatSubscribeBar extends StatefulWidget {
//   const UnlockChatSubscribeBar({
//     super.key,
//     required this.categoryCode,
//     required this.chatGroupId,
//     required this.supplyUser,
//   });
//   final UserDataModel supplyUser;
//   final CategoryCode categoryCode;
//   final int chatGroupId;
//   @override
//   State<UnlockChatSubscribeBar> createState() => _UnlockChatSubscribeBarState();
// }

// class _UnlockChatSubscribeBarState extends State<UnlockChatSubscribeBar> {
//   final _controllerFactory = sl<ChatSubscriptionControllerFactory>();

//   @override
//   void initState() {
//     super.initState();
//     sl<AnalyticsService>().trackEvent(
//       'chatPremiumAlert',
//       eventProperties: getEventProperties(),
//     );
//     final _chatSubscriptionController = _controllerFactory.create(
//         chatGroupId: widget.chatGroupId, category: widget.categoryCode.name);
//     Get.put(_chatSubscriptionController, tag: widget.chatGroupId.toString());
//   }

//   Map<String, dynamic> getEventProperties() {
//     final _eventProperites = {
//       'categoryName': widget.categoryCode.name,
//       'partnerName': widget.supplyUser.name ?? '',
//       'partnerNumber': widget.supplyUser.phoneNumber ?? '',
//       'partnerUid': widget.supplyUser.id ?? 0,
//       'groupId': widget.chatGroupId,
//     };
//     return _eventProperites;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       margin: const EdgeInsets.all(8.0),
//       width: double.infinity,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ChatLockedTimeBar(hasMargin: false),
//           const SizedBox(height: 8.0),
//           Container(
//             width: double.infinity,
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//                 gradient: LinearGradient(colors: [
//                   Color.fromRGBO(17, 26, 34, 1),
//                   Color.fromRGBO(29, 75, 108, 1)
//                 ])),
//             child: Column(children: [
//               Transform.translate(
//                 offset: Offset(0, -16.0),
//                 child: Container(
//                     alignment: Alignment.center,
//                     padding: const EdgeInsets.all(6.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Color(0x26000000),
//                           blurRadius: 20.0,
//                         ),
//                       ],
//                     ),
//                     child: Text(
//                       'or',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                           fontSize: FontSize.xL, fontWeight: FontWeight.bold),
//                     )),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 20.0),
//                 child: Text(
//                   "You've reached Daily Audio Limit",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: FontSize.xL,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//               GetBuilder<ChatSubscriptionController>(
//                   tag: widget.chatGroupId.toString(),
//                   builder: (controller) {
//                     if (controller.plans.isNotEmpty) {
//                       final plan = controller.plans.first;
//                       return SubscriptionButton(
//                         plan: plan,
//                         callback: () {
//                           if (controller.plans.length >= 2) {
//                             Get.bottomSheet(
//                               SubscriptionFeaturesBottomSheet(
//                                 firstPlan: controller.plans.first,
//                                 secondPlan: controller.plans.last,
//                                 supplyName: widget.supplyUser.name ?? '',
//                                 avatar: widget.supplyUser.avatar ??
//                                     AvatarService.getDemandAvatarUrl(),
//                                 chatGroupId: widget.chatGroupId,
//                                 eventProperties: getEventProperties(),
//                               ),
//                               isScrollControlled: true,
//                             );
//                           }
//                         },
//                       );
//                     } else {
//                       return const SizedBox.shrink();
//                     }
//                   })
//             ]),
//           ),
//         ],
//       ),
//     );
//   }
// }
