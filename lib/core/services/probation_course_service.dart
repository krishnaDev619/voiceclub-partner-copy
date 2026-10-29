import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/resources/usecase/usecase.dart';
import 'package:voiceclub_partner/data/models/course/probation_chapter.dart';
import 'package:voiceclub_partner/data/models/course/probation_lesson.dart';
import 'package:voiceclub_partner/data/models/course/remote/chapter_dto.dart';
import 'package:voiceclub_partner/domain/usecases/metrics/get_probation_details.dart';
import 'package:voiceclub_partner/view/course/probation_course_video_player_screen.dart';

class ProbationCourseService {
  static const _courseDataKey = 'course_data';
  static const _metricIntroVideoPlayedKey = 'metric_intro_video_played';

  Future<void> saveCourseData(List<ProbationChapter> chapters) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String jsonData = jsonEncode(
        chapters.map((chapter) => chapter.toJson()).toList(),
      );
      await prefs.setString(_courseDataKey, jsonData);
    } catch (e) {
      // Logger.logError("Error in saveCourseData in CourseDataService: $e");
    }
  }

  Future<List<ProbationChapter>> getCourseData({required bool isInit}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(_courseDataKey)) {
      final String? jsonData = prefs.getString(_courseDataKey);
      if (jsonData != null) {
        final List<dynamic> jsonList = jsonDecode(jsonData);
        final savedChapters =
            jsonList.map((json) => ProbationChapter.fromJson(json)).toList();
        if (isInit) {
          final mergedCourseData = await _getMergedCourseData(
            savedChapters: savedChapters,
          );
          await saveCourseData(mergedCourseData);
          return mergedCourseData;
        } else {
          return savedChapters;
        }
      }
    }
    final initCourseData = await _getInitialCourseData();
    await saveCourseData(initCourseData);
    return initCourseData;
  }

  Future<List<ChapterDto>> _getCourseDataFromAPI() async {
    try {
      final response = await sl<GetProbationDetailsUsecase>().call(NoParams());
      if (response.data != null) {
        final probationDetails = response.data;
        final courses = probationDetails?.tutorials ?? [];
        return [
          ChapterDto(
            name: "Probation",
            courses: courses,
            id: 0,
            isCompleted: probationDetails?.videoWatched ?? false,
          ),
        ];
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  Future<List<ProbationChapter>> _getMergedCourseData({
    required List<ProbationChapter> savedChapters,
  }) async {
    final dtoData = await _getCourseDataFromAPI();
    final chapters =
        dtoData.map((e) {
          final exisingChapter = savedChapters.firstWhereOrNull(
            (element) => element.id == e.id,
          );
          return ProbationChapter.fromDTO(
            chapterDto: e,
            existingChapter: exisingChapter,
          );
        }).toList();
    return chapters;
  }

  Future<List<ProbationChapter>> _getInitialCourseData() async {
    final dtoData = await _getCourseDataFromAPI();
    final chapters =
        dtoData
            .map(
              (e) => ProbationChapter.fromDTO(
                chapterDto: e,
                existingChapter: null,
              ),
            )
            .toList();
    return chapters;
  }

  // Method to fetch and play a single video
  Future<void> fetchAndPlayVideo({
    required ProbationLesson lesson,
    required int chapterId,
    bool fromOnboardingFlow = false,
  }) async {
    if (!lesson.isLocked) {
      try {
        Get.context?.loaderOverlay.show();
        final file = await DefaultCacheManager().getSingleFile(lesson.videoUrl);
        final path = file.path;
        if (path.isNotEmpty) {
          final videoPlayerController = VideoPlayerController.file(File(path));
          await videoPlayerController.initialize();

          Get.to(
            () => ProbationCourseVideoPlayerScreen(
              key: UniqueKey(),
              videoPlayerController: videoPlayerController,
              lesson: lesson,
              chapterId: chapterId,
              fromOnboardingFlow: fromOnboardingFlow,
            ),
          );
        }
      } catch (e) {
        // Logger.logError("Error in fetchAndPlayVideo in CourseDataService: $e");
      } finally {
        Get.context?.loaderOverlay.hide();
      }
    }
  }

  // Method to cache multiple videos
  Future<void> cacheVideos(List<String> urls) async {
    for (var url in urls) {
      try {
        await DefaultCacheManager().downloadFile(url);
      } catch (e) {
        // Logger.logError("Error in cacheVideos in CourseDataService: $e");
      }
    }
  }

  Future<void> setMetricIntroVideoPlayed({required bool hasPlayed}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_metricIntroVideoPlayedKey, hasPlayed);
  }

  Future<bool> getMetricIntroVideoPlayed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_metricIntroVideoPlayedKey) ?? false;
  }
}
