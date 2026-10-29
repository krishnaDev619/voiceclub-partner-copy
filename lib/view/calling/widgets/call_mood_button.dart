// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:voiceclub_partner/core/constants/asset_constants.dart';
// import 'package:voiceclub_partner/core/injection_container.dart';
// import 'package:voiceclub_partner/core/services/growthbook_service.dart';
// import 'package:voiceclub_partner/modules/controller/calls/incoming_call_controller.dart';

// class CallMoodButton extends StatefulWidget {
//   final bool isVisible;

//   const CallMoodButton({
//     super.key,
//     required this.isVisible,
//   });

//   @override
//   State<CallMoodButton> createState() => _CallMoodButtonState();
// }

// class _CallMoodButtonState extends State<CallMoodButton> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Visibility(
//       visible: widget.isVisible &&
//           sl<GrowthBookService>().getGrowthbookMoods() != null,
//       child: GestureDetector(
//         onTap: () async {
//           Get.find<IncomingCallController>().startMoodTesting();
//         },
//         child: Container(
//           margin: const EdgeInsets.only(top: 12.0),
//           padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8.0),
//             gradient: const LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [
//                 Color(0xFF2671E2),
//                 Color(0xFF264472),
//               ],
//             ),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SvgPicture.asset(AssetConstants.moodIcon),
//               const SizedBox(width: 4.0),
//               const Text(
//                 "User Mood",
//                 style: TextStyle(
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
