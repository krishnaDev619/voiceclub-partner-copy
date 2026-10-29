import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/tutorial/tutorial_quiz_model.dart';
import 'package:voiceclub_partner/view/tutorial/quiz/controller/quiz_controller.dart';

class QuizBinding extends Bindings {
  final TutorialStage currentStage;
  final TutorialQuizModel quizModel;

  QuizBinding({required this.currentStage, required this.quizModel});

  @override
  void dependencies() {
    Get.lazyPut<QuizController>(
      () => QuizController(currentStage: currentStage, quizModel: quizModel),
    );
  }
}
