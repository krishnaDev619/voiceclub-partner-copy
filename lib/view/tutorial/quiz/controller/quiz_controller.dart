import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/tutorial/mcq_tutorial_model.dart';
import 'package:voiceclub_partner/data/models/tutorial/tutorial_quiz_model.dart';
import 'package:voiceclub_partner/view/tutorial/quiz/widgets/quiz_result_dialog.dart';

class QuizController extends GetxController {
  final TutorialStage currentStage;
  final TutorialQuizModel quizModel;

  var selectedAnswerIndex = 100000.obs;
  var selectedAnswerId = 0.obs;
  var questionIndex = 1.obs;
  var isSubmitted = false.obs;
  AnswerState? answerState;
  var questionsMap = <int, MCQQuestionModel>{}.obs;
  final wrongQuestionMap = <String, int>{}.obs;

  QuizController({required this.currentStage, required this.quizModel}) {
    createQuestionMap(quizModel: quizModel);
  }

  void createQuestionMap({required TutorialQuizModel quizModel}) {
    var myList = quizModel.mcqQuestions;
    if (myList != null) {
      questionsMap.value = {
        for (int i = 0; i < myList.length; i++) i + 1: myList[i],
      };
    }
  }

  MCQQuestionModel getCurrentQuestion() {
    return questionsMap[questionIndex.value] ?? MCQQuestionModel();
  }

  void moveToNextQuestion() {
    if (questionIndex.value < questionsMap.keys.length) {
      questionsMap[questionIndex.value]?.selectedAnswerId =
          selectedAnswerId.value;
      questionIndex.value++;
      isSubmitted.value = false;
      selectedAnswerIndex.value = 100000;
      selectedAnswerId.value = 0;
      answerState = null;
    } else {
      questionsMap[questionIndex.value]?.selectedAnswerId =
          selectedAnswerId.value;
      calculateResults();
    }
  }

  void submitBtnClicked() {
    if (isSubmitted.value) {
      moveToNextQuestion();
    } else {
      isSubmitted.value = true;
      verifyAnswer();
    }
  }

  void verifyAnswer() {
    var correct =
        selectedAnswerId.value ==
        questionsMap[questionIndex.value]?.correctAnswerId;
    answerState = correct ? AnswerState.Correct : AnswerState.Incorrect;
    if (!correct) {
      wrongQuestionMap.addAll({
        questionsMap[questionIndex.value]?.question ?? "":
            selectedAnswerId.value,
      });
    }
  }

  void onOptionChanged({required int answerId, required int index}) {
    selectedAnswerId.value = answerId;
    selectedAnswerIndex.value = index;
    isSubmitted(true);
    verifyAnswer();
  }

  Future<void> calculateResults() async {
    var score =
        questionsMap.values
            .where((e) {
              return e.selectedAnswerId == e.correctAnswerId;
            })
            .toList()
            .length;
    var totalQuestionsLength = questionsMap.keys.length;
    var result = (score / totalQuestionsLength);
    var cutoff = 0.8; // Change the result cutoff as per requirements
    var isPassed = result >= (cutoff);
    Get.bottomSheet(
      QuizResultDialog(
        isPassed: isPassed,
        score: score,
        totalQuestions: totalQuestionsLength,
        quizModel: quizModel,
        currentStage: currentStage,
        wrongQuestionMap: wrongQuestionMap,
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }
}
