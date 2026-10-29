// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:voiceclub_partner/core/constants/ui_constants.dart';
// import 'package:voiceclub_partner/core/injection_container.dart';
// import 'package:voiceclub_partner/core/services/course_data_service.dart';
// import 'package:voiceclub_partner/modules/controller/course_controller.dart';

// class LessonTile extends StatelessWidget {
//   final int lessonId;
//   final int chapterId;

//   const LessonTile({
//     super.key,
//     required this.lessonId,
//     required this.chapterId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<CourseController>(
//       builder: (controller) {
//         final chapter = controller.chapters.firstWhereOrNull(
//           (element) => element.id == chapterId,
//         );
//         final lesson = chapter?.lessons.firstWhereOrNull(
//           (element) => element.id == lessonId,
//         );
//         if (lesson != null) {
//           return GestureDetector(
//             onTap: () {
//               sl<CourseDataService>().fetchAndPlayVideo(
//                 lesson: lesson,
//                 chapterId: chapterId,
//               );
//             },
//             child: Container(
//               margin: const EdgeInsets.symmetric(vertical: 10.0),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12.0),
//                 color: Colors.white,
//                 boxShadow: const [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 4.0,
//                     spreadRadius: 0.4,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         decoration: const BoxDecoration(
//                           color: Color(0xFFFFF1F1),
//                           borderRadius: BorderRadius.only(
//                               bottomRight: Radius.circular(12.0),
//                               topLeft: Radius.circular(12.0)),
//                         ),
//                         padding: const EdgeInsets.all(10.0),
//                         child: Text(
//                           chapter?.title ?? "",
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12.0,
//                           vertical: 8.0,
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.schedule,
//                               size: 18.0,
//                               color: Colors.grey,
//                             ),
//                             const SizedBox(width: 4.0),
//                             Text(
//                               lesson.getFormattedDuration,
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: FontSize.M,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   ListTile(
//                     key: UniqueKey(),
//                     tileColor: Colors.white,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12.0,
//                       vertical: 0.0,
//                     ),
//                     title: Text(
//                       lesson.title,
//                       maxLines: 2,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: FontSize.xL,
//                       ),
//                       textAlign: TextAlign.start,
//                     ),
//                     trailing: Container(
//                       height: 54.0,
//                       width: 54.0,
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(6.0),
//                         image: DecorationImage(
//                           image: FastCachedImageProvider(
//                             lesson.thumbnail,
//                           ),
//                           colorFilter: ColorFilter.mode(
//                             Colors.black.withValues(alpha:0.1),
//                             BlendMode.darken,
//                           ),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       child: const Icon(
//                         Icons.play_arrow_rounded,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 8.0,
//                   )
//                 ],
//               ),
//             ),
//           );
//         } else {
//           return const SizedBox.shrink();
//         }
//       },
//     );
//   }
// }
