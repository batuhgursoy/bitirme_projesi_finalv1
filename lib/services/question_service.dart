import 'package:hive/hive.dart';
import '../models/question.dart';
import '../data/sample_questions.dart';

class QuestionService {
  static late Box<Question> _questionBox;
  static const String _boxName = 'questions';

  // Service'i başlat
  static Future<void> init() async {
    _questionBox = await Hive.openBox<Question>(_boxName);

    // Eğer box boşsa, sample sorularını yükle
    // if (_questionBox.isEmpty) { // Temporarily commented out for debugging
    await _questionBox.clear(); // Ensure a clean slate
    await _loadInitialQuestions(); // Always load for now
    // }
  }

  // İlk kurulumda sample sorularını Hive'a kaydet
  static Future<void> _loadInitialQuestions() async {
    for (var question in sampleQuestions) {
      await _questionBox.add(question);
    }

    print('${sampleQuestions.length} soru Hive\'a kaydedildi.');
  }

  // Ders ve sınıfa göre soruları getir
  static List<Question> getQuestionsBySubjectAndGrade(
      String subject, int grade) {
    return _questionBox.values
        .where((question) =>
            question.subject == subject && question.grade == grade)
        .toList();
  }

  // Rastgele sorular getir
  static List<Question> getRandomQuestions(String subject, int grade,
      {int count = 10}) {
    final filteredQuestions = getQuestionsBySubjectAndGrade(subject, grade);

    if (filteredQuestions.length <= count) {
      return filteredQuestions;
    }

    // Karıştır ve istenen sayıda al
    filteredQuestions.shuffle();
    return filteredQuestions.take(count).toList();
  }

  // Yeni soru ekle
  static Future<void> addQuestion(Question question) async {
    await _questionBox.add(question);
  }

  // Soru güncelle
  static Future<void> updateQuestion(int index, Question question) async {
    await _questionBox.putAt(index, question);
  }

  // Soru sil
  static Future<void> deleteQuestion(int index) async {
    await _questionBox.deleteAt(index);
  }

  // Tüm soruları getir
  static List<Question> getAllQuestions() {
    return _questionBox.values.toList();
  }

  // Derslere göre soru sayısını getir
  static Map<String, int> getQuestionCountBySubject() {
    final Map<String, int> counts = {};

    for (var question in _questionBox.values) {
      counts[question.subject] = (counts[question.subject] ?? 0) + 1;
    }

    return counts;
  }

  // Sınıflara göre soru sayısını getir
  static Map<int, int> getQuestionCountByGrade() {
    final Map<int, int> counts = {};

    for (var question in _questionBox.values) {
      counts[question.grade] = (counts[question.grade] ?? 0) + 1;
    }

    return counts;
  }

  // Box'ı kapat
  static Future<void> close() async {
    await _questionBox.close();
  }

  // Tüm verileri temizle (debug için)
  static Future<void> clearAllData() async {
    await _questionBox.clear();
  }

  // Sample verileri yeniden yükle
  static Future<void> reloadSampleData() async {
    await _questionBox.clear();
    await _loadInitialQuestions();
  }
}
