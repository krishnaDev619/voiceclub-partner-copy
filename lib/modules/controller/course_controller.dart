// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:get/get.dart';
// import 'package:voiceclub_partner/core/injection_container.dart';
// import 'package:voiceclub_partner/core/services/course_data_service.dart';
// import 'package:voiceclub_partner/data/models/course/chapter.dart';
// import 'package:voiceclub_partner/data/models/course/lesson.dart';

// class CourseController extends GetxController {
//   final chapters = <Chapter>[].obs;
//   final allLessons = <Lesson>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchCourseData(true);
//   }

//   Future<void> fetchCourseData(bool isInit) async {
//     try {
//       chapters.clear();
//       chapters.add(Chapter(id: 0, title: "", lessons: []));
//       chapters.addAll(await sl<CourseDataService>().getInitialCourseData());
//       for (var chapter in chapters) {
//         allLessons.addAll(chapter.lessons);
//       }
//       _cacheVideos();
//     } catch (_) {
//       // Logger.logError('Error fetching course data: $e');
//     } finally {
//       update();
//     }
//   }

//   _cacheVideos() async {
//     try {
//       for (var lesson in allLessons) {
//         try {
//           await DefaultCacheManager().downloadFile(lesson.videoUrl);
//         } catch (_) {}
//       }
//     } catch (_) {}
//   }
// }
