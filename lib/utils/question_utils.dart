import '../models/question.dart';
import '../services/question_service.dart';

class QuestionUtils {
  // Artık sadece QuestionService'e yönlendirme yapıyor
  static List<Question> getRandomQuestions(String subject, int grade,
      {int count = 10}) {
    return QuestionService.getRandomQuestions(subject, grade, count: count);
  }

  // Ek yardımcı methodlar
  static List<Question> getAllQuestionsBySubject(String subject) {
    return QuestionService.getAllQuestions()
        .where((q) => q.subject == subject)
        .toList();
  }

  static List<Question> getAllQuestionsByGrade(int grade) {
    return QuestionService.getAllQuestions()
        .where((q) => q.grade == grade)
        .toList();
  }
}
