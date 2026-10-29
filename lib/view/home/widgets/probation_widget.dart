// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:voiceclub_partner/core/constants/ui_constants.dart';
// import 'package:voiceclub_partner/modules/controller/user_controller.dart';

// class ProbationWidget extends StatelessWidget {
//   const ProbationWidget({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<UserController>();
//     return Obx(() {
//       if (controller.isUnderProbation) {
//         return Container(
//           margin: const EdgeInsets.all(10.0),
//           padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(12.0),
//             color: Get.theme.primaryColor,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 "You are under probation",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: FontSize.xL,
//                 ),
//               ),
//               const SizedBox(
//                 width: 16.0,
//               ),
//               GestureDetector(
//                 onTap: () async {
//                   if (!controller.isLoadingVideo.value) {
//                     controller.fetchProbationVideo();
//                   }
//                 },
//                 child: Container(
//                   height: 48.0,
//                   width: 48.0,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                       color: Colors.white.withValues(alpha:0.3),
//                       borderRadius: BorderRadius.circular(12.0)),
//                   child: controller.isLoadingVideo.value
//                       ? const SizedBox(
//                           height: 16.0,
//                           width: 16.0,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 1.0,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Icon(
//                           Icons.play_arrow,
//                           size: 32.0,
//                           color: Colors.white,
//                         ),
//                 ),
//               )
//             ],
//           ),
//         );
//       } else {
//         return const SizedBox.shrink();
//       }
//     });
//   }
// }
