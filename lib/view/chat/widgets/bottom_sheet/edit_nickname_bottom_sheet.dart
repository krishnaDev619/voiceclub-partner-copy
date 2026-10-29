// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:loader_overlay/loader_overlay.dart';
// import 'package:pinput/pinput.dart';
// import 'package:voiceclub_partner/core/injection_container.dart';
// import 'package:voiceclub_partner/core/services/analytics_service.dart';
// import 'package:voiceclub_partner/domain/usecases/chat/update_custom_name.dart';
// import 'package:voiceclub_partner/modules/controller/chat_overview_controller.dart';
// import 'package:voiceclub_partner/view/widgets/custom_profile_picture.dart';

// class EditNicknameBottomSheet extends StatefulWidget {
//   const EditNicknameBottomSheet({
//     super.key,
//     required this.name,
//     required this.avatar,
//     required this.accountId,
//     required this.existingNickname,
//   });

//   final String name, avatar;
//   final int accountId;
//   final String? existingNickname;

//   @override
//   State<EditNicknameBottomSheet> createState() =>
//       _EditNicknameBottomSheetState();
// }

// class _EditNicknameBottomSheetState extends State<EditNicknameBottomSheet> {
//   final textController = TextEditingController();

//   @override
//   void initState() {
//     sl<AnalyticsService>().trackEvent(
//       "addNickname",
//       eventProperties: {
//         "existingNickname": widget.existingNickname,
//         "demandName": widget.name,
//         "demandAccountId": widget.accountId,
//       },
//     );
//     super.initState();
//     textController.setText(widget.existingNickname ?? "");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(10.0),
//       decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(12.0),
//             topRight: Radius.circular(12.0),
//           )),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           SizedBox(
//             child: Stack(
//               alignment: Alignment.topCenter,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const SizedBox(height: 42.0),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             widget.name,
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 18.0),
//                           ),
//                           const SizedBox(
//                             width: 4.0,
//                           ),
//                           const Icon(
//                             Icons.verified,
//                             color: Colors.blue,
//                           )
//                         ],
//                       ),
//                       const Padding(
//                         padding: EdgeInsets.symmetric(vertical: 12.0),
//                         child: Text(
//                           'Edit Nickname',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 14.0),
//                         ),
//                       ),
//                       Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             width: 0.1,
//                             color: Colors.black45,
//                           ),
//                           borderRadius: BorderRadius.circular(8),
//                           color: Colors.white,
//                         ),
//                         child: TextField(
//                           controller: textController,
//                           autofocus: true,
//                           maxLength: 16,
//                           onChanged: (_) {
//                             setState(() {});
//                           },
//                           maxLines: 1,
//                           maxLengthEnforcement: MaxLengthEnforcement.enforced,
//                           decoration: const InputDecoration(
//                             isCollapsed: true,
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: EdgeInsets.symmetric(
//                                 vertical: 4.0, horizontal: 10.0),
//                             fillColor: Colors.white,
//                             border: InputBorder.none,
//                             hintText: "Nickname",
//                             hintStyle: TextStyle(
//                               fontSize: 13,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Transform.translate(
//                   offset: const Offset(0, -60),
//                   child: CircleAvatar(
//                     radius: 60,
//                     backgroundColor: Colors.white,
//                     child: CustomProfilePicture(
//                       name: widget.name,
//                       avatarURL: widget.avatar,
//                       backgroundColor: Get.theme.primaryColor,
//                       radius: 56.0,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(
//             height: 12.0,
//           ),
//           GestureDetector(
//             onTap: () async {
//               try {
//                 final newNickname = textController.text.trim();
//                 if (newNickname.length >= 3 &&
//                     newNickname != widget.existingNickname) {
//                   FocusScope.of(context).unfocus();
//                   Get.context?.loaderOverlay.show();
//                   final response = await sl<UpdateCustomNameUseCase>().call(
//                     Params(
//                       name: newNickname,
//                       accountId: widget.accountId,
//                     ),
//                   );
//                   Get.context?.loaderOverlay.hide();
//                   if (response.error == null) {
//                     sl<AnalyticsService>().trackEvent(
//                       "nicknameAdded",
//                       eventProperties: {
//                         "newNickname": newNickname,
//                         "existingNickname": widget.existingNickname,
//                         "demandName": widget.name,
//                         "demandAccountId": widget.accountId,
//                       },
//                     );
//                     Get.find<ChatOverviewController>().fetchChats(page: 1);
//                     Get.back(result: textController.text.trim());
//                   }
//                 }
//               } catch (_) {
//                 Get.context?.loaderOverlay.hide();
//               }
//             },
//             child: Opacity(
//               opacity: (textController.text.trim().length >= 3 &&
//                       textController.text.trim() != widget.existingNickname)
//                   ? 1.0
//                   : 0.5,
//               child: Container(
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                     color: Get.theme.primaryColor,
//                     borderRadius: BorderRadius.circular(10)),
//                 child: const Center(
//                     child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Submit',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14),
//                     ),
//                   ],
//                 )),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
