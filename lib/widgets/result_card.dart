import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';

/// Quiz sonuçlarını gösteren kart widget'ı
/// Doğru/yanlış sayıları ve başarı yüzdesini gösterir
class ResultCard extends StatelessWidget {
  /// Doğru cevap sayısı
  final int correctAnswers;

  /// Yanlış cevap sayısı
  final int wrongAnswers;

  /// Toplam soru sayısı
  final int totalQuestions;

  const ResultCard({
    super.key,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.find<QuizController>();
    final double percentage = (correctAnswers / totalQuestions) * 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quiz Tamamlandı!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Doğru: $correctAnswers',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Yanlış: $wrongAnswers',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Başarı: %${percentage.toStringAsFixed(1)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              controller.resetQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Yeni Quiz Başlat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
