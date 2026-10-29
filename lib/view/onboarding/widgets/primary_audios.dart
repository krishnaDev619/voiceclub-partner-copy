// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:voiceclub_partner/core/constants/enums.dart';
// import 'package:voiceclub_partner/core/constants/ui_constants.dart';
// import 'package:voiceclub_partner/modules/controller/user_controller.dart';
// import 'package:voiceclub_partner/modules/controller/voice_controller.dart';
// import 'package:voiceclub_partner/view/widgets/custom_button.dart';

// class PrimaryAudios extends StatelessWidget {
//   const PrimaryAudios({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       final userDetails = Get.find<UserController>().userDetails.value;
//       final currentIndex = voiceController.currentIndex.value;
//       return Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(6.0),
//           color: const Color(0xFFFFF7F7),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black12,
//               blurRadius: 2.0,
//               spreadRadius: 1.0,
//             ),
//           ],
//         ),
//         margin: const EdgeInsets.all(16.0),
//         padding: const EdgeInsets.symmetric(vertical: 10.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(top: 16.0, left: 24.0),
//                 child: Row(
//                   children: [
//                     Text(
//                       userDetails.primaryLanguage ?? 'Hindi',
//                       style: const TextStyle(
//                         fontWeight: Weight.heavy,
//                         fontSize: FontSize.xL,
//                       ),
//                     ),
//                     const SizedBox(width: 4.0),
//                     const Text(
//                       "(1st Language)",
//                       style:
//                           TextStyle(color: Colors.grey, fontSize: FontSize.M),
//                     ),
//                   ],
//                 ),
//               ),
//               Stepper(
//                 controlsBuilder: (context, details) {
//                   return const SizedBox.shrink();
//                 },
//                 physics: const NeverScrollableScrollPhysics(),
//                 stepIconBuilder: (stepIndex, stepState) {
//                   if (stepState == StepState.complete) {
//                     return CircleAvatar(
//                       backgroundColor: Get.theme.primaryColor,
//                       child: const Icon(
//                         Icons.done,
//                         size: 16.0,
//                       ),
//                     );
//                   }
//                   return CircleAvatar(
//                     backgroundColor: stepState == StepState.editing ||
//                             stepIndex == currentIndex
//                         ? Get.theme.primaryColor
//                         : Colors.grey,
//                     child: Icon(
//                       _getIconByIndex(stepIndex),
//                       color: Colors.white,
//                       size: 16.0,
//                     ),
//                   );
//                 },
//                 onStepTapped: (value) {
//                   voiceController.onStepperTapped(value);
//                 },
//                 currentStep: currentIndex > 1 ? 1 : currentIndex,
//                 steps: [
//                   for (int i = 0; i < 2; i++)
//                     Step(
//                       title: Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               voiceController.audioStatusList[i].title ?? "",
//                               style:
//                                   const TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           const SizedBox(
//                             width: 4.0,
//                           ),
//                           (currentIndex != i &&
//                                   voiceController.audioStatusList[i]
//                                           .profileAudioStatus ==
//                                       ProfileAudioStatus.NotUploaded)
//                               ? const Icon(
//                                   Icons.lock,
//                                   color: Colors.grey,
//                                 )
//                               : voiceController
//                                       .audioStatusList[i].profileAudioStatus
//                                       ?.getStatusChip() ??
//                                   const SizedBox.shrink(),
//                         ],
//                       ),
//                       content: _recordNowBtn(i),
//                       state: getStepStatus(
//                         voiceController.audioStatusList[i].profileAudioStatus ??
//                             ProfileAudioStatus.NotUploaded,
//                       ),
//                       isActive: currentIndex >= i,
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }
