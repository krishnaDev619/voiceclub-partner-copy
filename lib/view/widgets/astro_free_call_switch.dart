// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:voiceclub_partner/core/constants/enums.dart';
// import 'package:voiceclub_partner/core/constants/ui_constants.dart';
// import 'package:voiceclub_partner/modules/controller/user_controller.dart';

// class AstroFreeCallSwitch extends StatefulWidget {
//   const AstroFreeCallSwitch({super.key});

//   @override
//   State<AstroFreeCallSwitch> createState() => _AstroFreeCallSwitchState();
// }

// class _AstroFreeCallSwitchState extends State<AstroFreeCallSwitch> {
//   final userController = Get.find<UserController>();
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       return Visibility(
//         visible: userController.userDetails.value.category?.categoryCode ==
//                 CategoryCode.ASTRO &&
//             userController.isOnline,
//         child: Padding(
//           padding: const EdgeInsets.only(
//             left: 10.0,
//             right: 10.0,
//             top: 8.0,
//           ),
//           child: ListTile(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             tileColor: Colors.white,
//             title: Text(
//               userController.acceptFreeCalls.value
//                   ? "Accepting FREE Calls Now!"
//                   : "FREE Calls RESTRICTED!",
//               style: const TextStyle(fontWeight: Weight.heavy),
//             ),
//             trailing: CupertinoSwitch(
//               trackColor: Colors.red,
//               value: userController.acceptFreeCalls.value,
//               onChanged: (_) async {
//                 userController.updateFreeCallStatus();
//               },
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }
