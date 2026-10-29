// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:get/get.dart';
// import 'package:loader_overlay/loader_overlay.dart';
// import 'package:video_player/video_player.dart';
// import 'package:voiceclub_partner/core/injection_container.dart';
// import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
// import 'package:voiceclub_partner/data/models/course/chapter.dart';
// import 'package:voiceclub_partner/data/models/course/lesson.dart';
// import 'package:voiceclub_partner/data/models/course/remote/chapter_dto.dart';
// import 'package:voiceclub_partner/domain/usecases/course/get_course.dart';
// import 'package:voiceclub_partner/view/course/course_video_player_screen.dart';

// class CourseDataService {
//   Future<List<ChapterDto>> _getCourseDataFromAPI() async {
//     try {
//       final response = await sl<GetCourseUsecase>().call(NoParams());
//       if (response.data != null && response.error == null) {
//         return response.data?.allChapters ?? [];
//       } else {
//         return [];
//       }
//     } catch (_) {
//       return [];
//     }
//   }

//   Future<List<Chapter>> getInitialCourseData() async {
//     final dtoData = await _getCourseDataFromAPI();
//     final chapters = dtoData
//         .map((e) => Chapter.fromDTO(chapterDto: e, existingChapter: null))
//         .toList();
//     return chapters;
//   }

//   // Method to fetch and play a single video
//   Future<void> fetchAndPlayVideo({
//     required Lesson lesson,
//     required int chapterId,
//   }) async {
//     try {
//       Get.context?.loaderOverlay.show();
//       final file = await DefaultCacheManager().getSingleFile(lesson.videoUrl);
//       final path = file.path;
//       if (path.isNotEmpty) {
//         final videoPlayerController = VideoPlayerController.file(File(path));
//         await videoPlayerController.initialize();

//         Get.to(
//           () => CourseVideoPlayerScreen(
//             key: UniqueKey(),
//             videoPlayerController: videoPlayerController,
//             lesson: lesson,
//             chapterId: chapterId,
//           ),
//         );
//       }
//     } catch (e) {
//       // Logger.logError("Error in fetchAndPlayVideo in CourseDataService: $e");
//     } finally {
//       Get.context?.loaderOverlay.hide();
//     }
//   }
// }
