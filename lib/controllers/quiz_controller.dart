import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/question_service.dart';

/// Quiz akışını ve durumunu yöneten controller sınıfı
/// GetX state management kullanılarak implement edilmiştir
class QuizController extends GetxController {
  /// Seçilen ders
  final RxString selectedSubject = ''.obs;

  /// Seçilen sınıf seviyesi
  final RxInt selectedGrade = 0.obs;

  /// Aktif quiz için yüklenen sorular
  final RxList<Question> questions = <Question>[].obs;

  /// Şu anki sorunun indeksi
  final RxInt currentQuestionIndex = 0.obs;

  /// Kullanıcının verdiği cevaplar
  final RxList<int> userAnswers = <int>[].obs;

  /// Quiz'in tamamlanma durumu
  final RxBool isQuizCompleted = false.obs;

  /// Öğrenci adı
  final RxString studentName = ''.obs;

  /// Seçilen cevap indeksi
  RxInt selectedAnswer = (-1).obs;

  /// Doğru cevap indeksi
  RxInt correctAnswerIndex = (-1).obs;

  /// Cevabın doğruluğu
  RxBool isAnswerCorrect = false.obs;

  /// Sonuç gösterme durumu
  RxBool showResult = false.obs;

  /// Ders seçimini günceller
  void selectSubject(String subject) {
    selectedSubject.value = subject;
  }

  /// Sınıf seviyesini günceller
  void selectGrade(int grade) {
    selectedGrade.value = grade;
  }

  /// Seçilen ders ve sınıf için soruları yükler
  void loadQuestions() {
    if (selectedSubject.value.isEmpty || selectedGrade.value == 0) {
      questions.clear();
      return;
    }

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

    _resetQuizState();
    print('${questions.length} soru yüklendi.');
  }

  /// Yeni soru ekler
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

  /// Soru istatistiklerini getirir
  Map<String, int> getQuestionStats() {
    return QuestionService.getQuestionCountBySubject();
  }

  /// Kullanıcının seçtiği cevabı işler
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

  /// Bir sonraki soruya geçer
  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      _resetAnswerState();
    } else {
      isQuizCompleted.value = true;
      Get.offAllNamed('/result');
    }
  }

  /// Seçilen cevabın doğruluğunu kontrol eder
  bool checkAnswer(String option) {
    final currentQuestion = questions[currentQuestionIndex.value];
    final optionIndex = currentQuestion.options.indexOf(option);
    return optionIndex == currentQuestion.correctAnswerIndex;
  }

  /// Doğru cevap sayısını hesaplar
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

  /// Yanlış cevap sayısını hesaplar
  int get wrongAnswers {
    if (userAnswers.isEmpty) return 0;
    return userAnswers.length - correctAnswers;
  }

  /// Quiz'i tamamen sıfırlar ve ana ekrana döner
  void resetQuiz() {
    selectedSubject.value = '';
    selectedGrade.value = 0;
    questions.clear();
    _resetQuizState();
    Get.offAllNamed('/welcome');
  }

  /// Quiz durumunu sıfırlar
  void _resetQuizState() {
    userAnswers.clear();
    currentQuestionIndex.value = 0;
    isQuizCompleted.value = false;
    _resetAnswerState();
  }

  /// Cevap durumunu sıfırlar
  void _resetAnswerState() {
    selectedAnswer.value = -1;
    correctAnswerIndex.value = -1;
    isAnswerCorrect.value = false;
    showResult.value = false;
  }

  @override
  void onClose() {
    QuestionService.close();
    super.onClose();
  }
}
