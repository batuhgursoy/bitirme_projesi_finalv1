import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import '../widgets/question_card.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.find<QuizController>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getSubjectColorLight(controller.selectedSubject.value),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.questions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 60, 
                      height: 60,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getSubjectColor(controller.selectedSubject.value),
                        ),
                        backgroundColor: Colors.white,
                        strokeWidth: 6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Sorular Yükleniyor...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getSubjectColor(controller.selectedSubject.value),
                      ),
                    ),
                  ],
                ),
              );
            }

            final currentQuestion = controller.questions[controller.currentQuestionIndex.value];

            return QuestionCard(
              question: currentQuestion,
              subjectColor: _getSubjectColor(controller.selectedSubject.value),
              onAnswerSelected: (index) {
                if (controller.showResult.value) return;
                
                controller.selectAnswer(currentQuestion.options[index]);
                
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (controller.currentQuestionIndex.value < controller.questions.length - 1) {
                    controller.nextQuestion();
                  } else {
                    Get.offAllNamed('/result');
                  }
                });
              },
            );
          }),
        ),
      ),
    );
  }
  
  Color _getSubjectColor(String subject) {
    switch(subject) {
      case 'Türkçe':
        return const Color(0xFFFFA726);  // Turuncu
      case 'Matematik':
        return const Color(0xFF7C4DFF);  // Mor
      case 'Hayat Bilgisi':
        return const Color(0xFF4CAF50);  // Yeşil
      case 'İngilizce':
        return const Color(0xFF42A5F5);  // Mavi
      default:
        return const Color(0xFF156DB4);  // Varsayılan mavi
    }
  }
  
  Color _getSubjectColorLight(String subject) {
    switch(subject) {
      case 'Türkçe':
        return const Color(0xFFFFE0B2);  // Açık turuncu
      case 'Matematik':
        return const Color(0xFFE1D4FF);  // Açık mor
      case 'Hayat Bilgisi':
        return const Color(0xFFDCEDC8);  // Açık yeşil
      case 'İngilizce':
        return const Color(0xFFBBDEFB);  // Açık mavi
      default:
        return const Color(0xFFCFE9FC);  // Varsayılan açık mavi
    }
  }
}