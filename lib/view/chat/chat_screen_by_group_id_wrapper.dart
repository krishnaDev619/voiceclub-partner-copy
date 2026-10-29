// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:voiceclub_partner/core/constants/enums.dart';
// import 'package:voiceclub_partner/core/injection_container.dart';
// import 'package:voiceclub_partner/domain/usecases/chat/get_chat_group_by_id.dart';
// import 'package:voiceclub_partner/modules/controller/chat_screen_by_group_id_controller.dart';
// import 'package:voiceclub_partner/modules/controller/user_controller.dart';
// import 'package:voiceclub_partner/modules/controller/supply/supply_user_controller.dart';
// import 'package:voiceclub_partner/view/chat/chat_screen.dart';

// class ChatScreenByGroupIdWrapper extends StatefulWidget {
//   final int groupId;
//   final bool isDemand;
//   final bool isNew;
//   const ChatScreenByGroupIdWrapper({
//     super.key,
//     required this.groupId,
//     required this.isDemand,
//     this.isNew = false,
//   });

//   @override
//   State<ChatScreenByGroupIdWrapper> createState() =>
//       _ChatScreenByGroupIdWrapperState();
// }

// class _ChatScreenByGroupIdWrapperState
//     extends State<ChatScreenByGroupIdWrapper> {
//   @override
//   void initState() {
//     final _chatScreenController = ChatScreenByGroupIdController(
//         getChatGroupByIdUsecase: sl<GetChatGroupByIdUsecase>(),
//         groupId: widget.groupId);
//     Get.put(_chatScreenController);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ChatScreenByGroupIdController>(builder: (controller) {
//       if (controller.isLoading.value) {
//         return Scaffold(
//           body: Center(
//             child: CircularProgressIndicator(),
//           ),
//         );
//       } else if (controller.isError.value) {
//         return Scaffold(
//           body: Center(
//             child: Text('Something went wrong.'),
//           ),
//         );
//       } else {
//         try {
//           int selfAccountId = 0;
//           if (widget.isDemand) {
//             selfAccountId =
//                 Get.find<UserController>().userDetails.accountId ?? 0;
//           } else {
//             selfAccountId =
//                 Get.find<UserController>().userDetails.value.accountId ??
//                     0;
//           }
//           if (selfAccountId != 0) {
//             return ChatScreen(
//               chatGroup: controller.chatGroup.value,
//               categoryCode:
//                   controller.chatGroup.value.category ?? CategoryCode.GOSSIP,
//               selfAccountId: selfAccountId,
//               isDemand: widget.isDemand,
//               isNew: widget.isNew,
//             );
//           } else {
//             return Scaffold(
//               body: Center(
//                 child: Text('Something went wrong.'),
//               ),
//             );
//           }
//         } catch (_) {
//           return Scaffold(
//             body: Center(
//               child: Text('Something went wrong.'),
//             ),
//           );
//         }
//       }
//     });
//   }
// }
