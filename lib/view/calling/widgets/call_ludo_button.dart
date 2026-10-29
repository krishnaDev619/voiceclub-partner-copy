// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:showcaseview/showcaseview.dart';
// import 'package:voiceclub_partner/core/constants/asset_constants.dart';
// import 'package:voiceclub_partner/modules/controller/calls/incoming_call_controller.dart';
// import 'package:voiceclub_partner/view/widgets/showcase_view_ludo.dart';

// class CallLudoButton extends StatefulWidget {
//   final bool isAccepted;

//   const CallLudoButton({
//     super.key,
//     required this.isAccepted,
//   });

//   @override
//   State<CallLudoButton> createState() => _CallLudoButtonState();
// }

// class _CallLudoButtonState extends State<CallLudoButton> {
//   final showcaseKey = GlobalKey();

//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       Get.find<IncomingCallController>().showShowcase.listen((p0) {
//         if (p0) {
//           ShowCaseWidget.of(context).startShowCase([showcaseKey]);
//         } else {
//           ShowCaseWidget.of(context).dismiss();
//         }
//       });
//     });

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Visibility(
//       visible: widget.isAccepted,
//       child: GestureDetector(
//         onTap: () async {
//           Get.find<IncomingCallController>().startLudo();
//         },
//         child: Padding(
//           padding: const EdgeInsets.only(left: 10.0),
//           child: Showcase.withWidget(
//             height: 80.0,
//             width: 100.0,
//             targetBorderRadius: BorderRadius.circular(6.0),
//             targetPadding: const EdgeInsets.all(3.0),
//             key: showcaseKey,
//             container: const ShowcaseViewLudo(title: 'Play Ludo'),
//             onTargetClick: () {
//               ShowCaseWidget.of(context).dismiss();
//               Get.find<IncomingCallController>().startLudo();
//             },
//             child: Container(
//               margin: const EdgeInsets.only(top: 12.0),
//               padding:
//                   const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8.0),
//                 gradient: const LinearGradient(
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                   colors: [
//                     Color(0xFF2671E2),
//                     Color(0xFF264472),
//                   ],
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   SvgPicture.asset(AssetConstants.ludoIcon),
//                   const SizedBox(width: 4.0),
//                   const Text(
//                     "Ludo",
//                     style: TextStyle(
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
