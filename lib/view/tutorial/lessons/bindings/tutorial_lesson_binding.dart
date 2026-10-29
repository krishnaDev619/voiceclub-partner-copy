import 'package:get/get.dart';
import 'package:voiceclub_partner/view/tutorial/lessons/controllers/tutorial_lesson_controller.dart';

class TutorialLessonBinding extends Bindings {
  final int initCompletedLessonId;

  TutorialLessonBinding({required this.initCompletedLessonId});

  @override
  void dependencies() {
    Get.put(
      TutorialLessonController(initCompletedLessonId: initCompletedLessonId),
    );
  }
}
