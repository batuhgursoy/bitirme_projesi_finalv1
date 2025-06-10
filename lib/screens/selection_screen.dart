import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import 'quiz_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.put(QuizController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ders ve Sınıf Seçimi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ders Seçiniz',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => controller.selectSubject('Türkçe'),
                  child: const Text('Türkçe'),
                ),
                ElevatedButton(
                  onPressed: () => controller.selectSubject('Matematik'),
                  child: const Text('Matematik'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Sınıf Seçiniz',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => controller.selectGrade(1),
                  child: const Text('1. Sınıf'),
                ),
                ElevatedButton(
                  onPressed: () => controller.selectGrade(2),
                  child: const Text('2. Sınıf'),
                ),
                ElevatedButton(
                  onPressed: () => controller.selectGrade(3),
                  child: const Text('3. Sınıf'),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Obx(() => ElevatedButton(
                  onPressed: (controller.selectedSubject.isNotEmpty &&
                          controller.selectedGrade.value > 0)
                      ? () {
                          controller.loadQuestions();
                          Get.to(() => const QuizScreen());
                        }
                      : null,
                  child: const Text('Teste Başla'),
                )),
          ],
        ),
      ),
    );
  }
} 