// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:voiceclub_partner/core/constants/asset_constants.dart';
// import 'package:voiceclub_partner/core/constants/enums.dart';
// import 'package:voiceclub_partner/core/constants/ui_constants.dart';
// import 'package:voiceclub_partner/core/injection_container.dart';
// import 'package:voiceclub_partner/core/services/analytics_service.dart';
// import 'package:voiceclub_partner/data/models/config/subscription_plan.dart';
// import 'package:voiceclub_partner/modules/controller/chat_subscription_controller.dart';
// import 'package:voiceclub_partner/modules/controller/wallet_controller.dart';
// import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/confirmation_popup.dart';
// import 'package:voiceclub_partner/view/chat/widgets/bottom_sheet/congratulations_bottom_sheet.dart';
// import 'package:voiceclub_partner/view/chat/widgets/chat_locked_time_bar.dart';
// import 'package:voiceclub_partner/view/chat/widgets/feature_comparison_widget.dart';
// import 'package:voiceclub_partner/view/chat/widgets/select_plan_button.dart';
// import 'package:voiceclub_partner/view/chat/widgets/subscription_button.dart';

// class OldSubscriptionFeaturesBottomSheet extends StatefulWidget {
//   final String supplyName, avatar;
//   final CategoryCode categoryCode;
//   final int chatGroupId;
//   final Map<String, dynamic> eventProperties;
//   const OldSubscriptionFeaturesBottomSheet({
//     required this.supplyName,
//     required this.categoryCode,
//     required this.avatar,
//     required this.chatGroupId,
//     required this.eventProperties,
//     super.key,
//   });

//   @override
//   State<OldSubscriptionFeaturesBottomSheet> createState() =>
//       _OldSubscriptionFeaturesBottomSheetState();
// }

// class _OldSubscriptionFeaturesBottomSheetState
//     extends State<OldSubscriptionFeaturesBottomSheet> {
//   final _chatSubscriptionControllerFactory =
//       sl<ChatSubscriptionControllerFactory>();
//   SubscriptionPlan? selectedPlan;

//   @override
//   void initState() {
//     final _chatSubscriptionController =
//         _chatSubscriptionControllerFactory.create(
//             chatGroupId: widget.chatGroupId,
//             category: widget.categoryCode.name);
//     Get.put(_chatSubscriptionController, tag: widget.chatGroupId.toString());
//     sl<AnalyticsService>().trackEvent(
//       'chatPremiumPlanBottomSheet',
//       eventProperties: widget.eventProperties,
//     );
//     super.initState();
//   }

//   Map<String, dynamic> getEventProperties(SubscriptionPlan? plan) {
//     Map<String, dynamic> _properties = widget.eventProperties;
//     _properties['selectedPlanId'] = plan?.id ?? 0;
//     _properties['selectedPlanPrice'] = plan?.price ?? 0;
//     _properties['selectedPlanDays'] = plan?.durationInDays ?? 0;
//     return _properties;
//   }

//   void changePlan(SubscriptionPlan newPlan) {
//     setState(() {
//       selectedPlan = newPlan;
//     });
//     sl<AnalyticsService>().trackEvent(
//       'changePlanSelection',
//       eventProperties: getEventProperties(newPlan),
//     );
//   }

//   final icons = <Widget>[
//     Icon(
//       Icons.mic,
//       size: 20.0,
//       color: Color(0xFF192D3D),
//     ),
//     SvgPicture.asset(
//       AssetConstants.extendAudioIcon,
//       height: 20.0,
//     ),
//     Icon(
//       Icons.remove_red_eye_rounded,
//       size: 20.0,
//       color: Color(0xFF192D3D),
//     ),
//     Icon(
//       Icons.history,
//       size: 20.0,
//       color: Color(0xFF192D3D),
//     )
//   ];

//   List<Widget> getFeatureComparisonWidgets(
//       SubscriptionPlan first, SubscriptionPlan second) {
//     final _widgets = <Widget>[];
//     try {
//       for (int i = 0; i <= (first.items?.length ?? 0); i++) {
//         final item1 = first.items?[i];
//         final item2 = second.items?[i];
//         if (item1 != null && item2 != null && i < 4) {
//           _widgets.add(FeatureComparisonWidget(
//             icon: icons[i],
//             item1: item1,
//             item2: item2,
//           ));
//         }
//       }
//     } catch (_) {}
//     return _widgets;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(12.0), topRight: Radius.circular(12.0)),
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF192D3D),
//               Color(0xFF245B81),
//             ],
//             stops: [0.0, 1.0],
//             tileMode: TileMode.clamp,
//           ),
//         ),
//         child: GetBuilder<ChatSubscriptionController>(
//             tag: widget.chatGroupId.toString(),
//             builder: (controller) {
//               if (controller.isLoading.value) {
//                 return Padding(
//                   padding: EdgeInsets.symmetric(
//                       vertical: MediaQuery.of(context).size.height / 2.5,
//                       horizontal:
//                           (MediaQuery.of(context).size.width / 2) - 16.0),
//                   child: SizedBox(
//                     height: 32.0,
//                     width: 32.0,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 1.5,
//                     ),
//                   ),
//                 );
//               } else {
//                 if (controller.plans.length >= 2) {
//                   final firstPlan = controller.plans.first;
//                   final secondPlan = controller.plans.last;
//                   if (selectedPlan == null) {
//                     selectedPlan = firstPlan;
//                   }
//                   return Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                         child: Stack(
//                           alignment: Alignment.topCenter,
//                           children: [
//                             Container(
//                               child: Column(
//                                 children: [
//                                   const SizedBox(
//                                     height: 40.0,
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                         vertical: 16.0),
//                                     child: Text(
//                                       'Upgrade Chat with ${widget.supplyName}',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: FontSize.xL,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                   ChatLockedTimeBar(
//                                     hasMargin: false,
//                                     isBottomSheet: false,
//                                   ),
//                                   const SizedBox(
//                                     height: 16.0,
//                                   ),
//                                   Row(
//                                     children: [
//                                       SelectPlanButton(
//                                           plan: firstPlan,
//                                           isSelected: firstPlan == selectedPlan,
//                                           callback: () {
//                                             changePlan(firstPlan);
//                                           }),
//                                       const SizedBox(width: 12.0),
//                                       SelectPlanButton(
//                                           plan: secondPlan,
//                                           isSelected:
//                                               secondPlan == selectedPlan,
//                                           callback: () {
//                                             changePlan(secondPlan);
//                                           })
//                                     ],
//                                   ),
//                                   const SizedBox(height: 16.0),
//                                 ],
//                               ),
//                             ),
//                             Transform.translate(
//                               offset: Offset(0, -40),
//                               child: CircleAvatar(
//                                 radius: 40,
//                                 backgroundColor: Color(0xFF5DBBFF),
//                                 backgroundImage:
//                                     FastCachedImageProvider(widget.avatar),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                           width: double.infinity,
//                           color: Color(0xFFF6F6F6),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Container(
//                                 width: double.infinity,
//                                 alignment: Alignment.center,
//                                 margin: const EdgeInsets.all(10.0),
//                                 padding: const EdgeInsets.all(12.0),
//                                 decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(10.0)),
//                                 child: Column(
//                                   children: [
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           top: 4.0, bottom: 16.0),
//                                       child: Text(
//                                         'Upgraded Daily Features',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           color: Color(0xFF192D3D),
//                                           fontSize: FontSize.xL,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ),
//                                     ...getFeatureComparisonWidgets(
//                                         firstPlan, secondPlan),
//                                   ],
//                                 ),
//                               ),
//                               SubscriptionButton(
//                                 plan: selectedPlan ?? firstPlan,
//                                 callback: () async {
//                                   sl<AnalyticsService>().trackEvent(
//                                     'chatPremiumInitiate',
//                                     eventProperties:
//                                         getEventProperties(selectedPlan),
//                                   );
//                                   // Call confirmation bottom sheet
//                                   bool _confirmed = await Get.bottomSheet<bool>(
//                                         ConfirmationPopup(
//                                           name: widget.supplyName,
//                                           amount: selectedPlan?.price ?? 199,
//                                         ),
//                                       ) ??
//                                       false;
//                                   // If confirmed, call subscribeChat
//                                   if (_confirmed) {
//                                     final _chatSubscriptionController =
//                                         Get.find<ChatSubscriptionController>(
//                                             tag: widget.chatGroupId.toString());
//                                     final _subscribed =
//                                         await _chatSubscriptionController
//                                             .subscribeChat(
//                                                 planId: selectedPlan?.id ?? 0,
//                                                 context: context,
//                                                 supplyName: widget.supplyName);
//                                     if (_subscribed) {
//                                       sl<AnalyticsService>().trackEvent(
//                                         'chatPremiumSuccess',
//                                         eventProperties:
//                                             getEventProperties(selectedPlan),
//                                       );
//                                       // Fetch wallet data
//                                       Get.find<WalletController>().fetchData();
//                                       Get.back();
//                                       Get.bottomSheet(
//                                         CongratulationsBottomSheet(
//                                           supplyName: widget.supplyName,
//                                           avatar: widget.avatar,
//                                         ),
//                                         isDismissible: false,
//                                       );
//                                     } else {
//                                       sl<AnalyticsService>().trackEvent(
//                                         'chatPremiumFail',
//                                         eventProperties:
//                                             getEventProperties(selectedPlan),
//                                       );
//                                     }
//                                   }
//                                 },
//                               ),
//                             ],
//                           )),
//                     ],
//                   );
//                 } else {
//                   return Center(
//                     child: Text(
//                       "Something went wrong.\nPlease try again later.",
//                       textAlign: TextAlign.center,
//                     ),
//                   );
//                 }
//               }
//             }),
//       ),
//     );
//   }
// }
