import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/tutorial/demo_question_model.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_audio_button_controller.dart';
import 'package:voiceclub_partner/view/tutorial/demo/controllers/demo_landing_controller.dart';

class DemoLandingBinding extends Bindings {
  final TutorialStage currentStage;
  final List<DemoQuestionModel> demoQuestions;

  DemoLandingBinding({required this.currentStage, required this.demoQuestions});

  @override
  void dependencies() {
    Get.lazyPut(() => DemoAudioButtonController());
    Get.lazyPut<DemoLandingController>(
      () => DemoLandingController(
        currentStage: currentStage,
        demoQuestions: demoQuestions,
      ),
    );
  }
}
