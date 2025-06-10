import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';

class QuizController extends GetxController {
  final RxString selectedSubject = ''.obs;
  final RxInt selectedGrade = 0.obs;
  final RxList<Question> questions = <Question>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxList<int> userAnswers = <int>[].obs;
  final RxBool isQuizCompleted = false.obs;
  final RxString studentName = ''.obs;
  RxInt selectedAnswer = (-1).obs;
  RxInt correctAnswerIndex = (-1).obs;
  RxBool isAnswerCorrect = false.obs;
  RxBool showResult = false.obs;

  void selectSubject(String subject) {
    selectedSubject.value = subject;
  }

  void selectGrade(int grade) {
    selectedGrade.value = grade;
  }

  void loadQuestions() {
    if (selectedSubject.value.isEmpty || selectedGrade.value == 0) {
      questions.clear();
      return;
    }

    // Hive'dan soruları yükle
    questions.value = QuestionService.getRandomQuestions(
      selectedSubject.value,
      selectedGrade.value,
    );

    if (questions.isEmpty) {
      Get.snackbar(
        'Uyarı',
        'Seçilen ders ve sınıf için soru bulunamadı!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black87,
        margin: const EdgeInsets.all(20),
        borderRadius: 15,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    userAnswers.clear();
    currentQuestionIndex.value = 0;
    isQuizCompleted.value = false;
    selectedAnswer.value = -1;
    correctAnswerIndex.value = -1;
    isAnswerCorrect.value = false;
    showResult.value = false;

    print('${questions.length} soru Hive\'dan yüklendi.');
  }

  // Yeni soru ekleme methodu
  Future<void> addNewQuestion(Question question) async {
    await QuestionService.addQuestion(question);
    Get.snackbar(
      'Başarılı',
      'Yeni soru eklendi!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // İstatistik bilgileri
  Map<String, int> getQuestionStats() {
    return QuestionService.getQuestionCountBySubject();
  }

  void selectAnswer(String option) {
    if (showResult.value) return;

    final currentQuestion = questions[currentQuestionIndex.value];
    final optionIndex = currentQuestion.options.indexOf(option);

    selectedAnswer.value = optionIndex;
    correctAnswerIndex.value = currentQuestion.correctAnswerIndex;
    isAnswerCorrect.value = (optionIndex == correctAnswerIndex.value);
    showResult.value = true;

    if (userAnswers.length <= currentQuestionIndex.value) {
      userAnswers.add(optionIndex);
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      selectedAnswer.value = -1;
      correctAnswerIndex.value = -1;
      isAnswerCorrect.value = false;
      showResult.value = false;
    } else {
      isQuizCompleted.value = true;
      Get.offAllNamed('/result');
    }
  }

  bool checkAnswer(String option) {
    final currentQuestion = questions[currentQuestionIndex.value];
    final optionIndex = currentQuestion.options.indexOf(option);
    return optionIndex == currentQuestion.correctAnswerIndex;
  }

  int get correctAnswers {
    if (userAnswers.isEmpty) return 0;
    int count = 0;
    for (int i = 0; i < userAnswers.length && i < questions.length; i++) {
      if (userAnswers[i] == questions[i].correctAnswerIndex) {
        count++;
      }
    }
    return count;
  }

  int get wrongAnswers {
    if (userAnswers.isEmpty) return 0;
    return userAnswers.length - correctAnswers;
  }

  void resetQuiz() {
    selectedSubject.value = '';
    selectedGrade.value = 0;
    questions.clear();
    currentQuestionIndex.value = 0;
    userAnswers.clear();
    isQuizCompleted.value = false;
    selectedAnswer.value = -1;
    correctAnswerIndex.value = -1;
    isAnswerCorrect.value = false;
    showResult.value = false;
    Get.offAllNamed('/welcome');
  }

  @override
  void onClose() {
    QuestionService.close();
    super.onClose();
  }
}
