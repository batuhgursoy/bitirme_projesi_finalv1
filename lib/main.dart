import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/welcome_screen.dart';
import 'screens/subject_selection_screen.dart';
import 'screens/grade_selection_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';
import 'controllers/quiz_controller.dart';
import 'models/question.dart';
import 'services/question_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive'ı başlat
  await Hive.initFlutter();

  // Adapter'ları kaydet
  Hive.registerAdapter(QuestionAdapter());

  // Question service'i başlat (ilk kurulumda soruları yükler)
  await QuestionService.init();

  // QuizController'ı başlat
  Get.put(QuizController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'İlkokul Quiz Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/welcome',
      getPages: [
        GetPage(name: '/welcome', page: () => const WelcomeScreen()),
        GetPage(
            name: '/subject-selection',
            page: () => const SubjectSelectionScreen()),
        GetPage(
            name: '/grade-selection', page: () => const GradeSelectionScreen()),
        GetPage(name: '/quiz', page: () => const QuizScreen()),
        GetPage(name: '/result', page: () => const ResultScreen()),
      ],
    );
  }
}
