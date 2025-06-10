import 'package:hive/hive.dart';
import '../models/question.dart';
import '../data/sample_questions.dart';

/// Soru yönetimi için merkezi servis sınıfı.
/// Hive veritabanı ile entegre çalışır ve tüm CRUD operasyonlarını yönetir.
class QuestionService {
  static late Box<Question> _questionBox;
  static const String _boxName = 'questions';

  /// Servis başlatma işlemi
  /// Hive veritabanını açar ve örnek soruları yükler
  static Future<void> init() async {
    _questionBox = await Hive.openBox<Question>(_boxName);
    await _questionBox.clear();
    await _loadInitialQuestions();
  }

  /// Örnek soruları veritabanına yükler
  /// Uygulama ilk çalıştığında veya test amaçlı kullanılır
  static Future<void> _loadInitialQuestions() async {
    for (var question in sampleQuestions) {
      await _questionBox.add(question);
    }
    print('${sampleQuestions.length} soru Hive veritabanına kaydedildi.');
  }

  /// Belirli bir ders ve sınıf seviyesine ait soruları getirir
  /// @param subject - Dersin adı
  /// @param grade - Sınıf seviyesi
  static List<Question> getQuestionsBySubjectAndGrade(
      String subject, int grade) {
    return _questionBox.values
        .where((question) =>
            question.subject == subject && question.grade == grade)
        .toList();
  }

  /// Belirli bir ders ve sınıf seviyesinden rastgele sorular getirir
  /// @param subject - Dersin adı
  /// @param grade - Sınıf seviyesi
  /// @param count - İstenen soru sayısı (varsayılan: 10)
  static List<Question> getRandomQuestions(String subject, int grade,
      {int count = 10}) {
    final filteredQuestions = getQuestionsBySubjectAndGrade(subject, grade);

    if (filteredQuestions.length <= count) {
      return filteredQuestions;
    }

    filteredQuestions.shuffle();
    return filteredQuestions.take(count).toList();
  }

  /// Yeni bir soru ekler
  /// @param question - Eklenecek soru nesnesi
  static Future<void> addQuestion(Question question) async {
    await _questionBox.add(question);
  }

  /// Var olan bir soruyu günceller
  /// @param index - Güncellenecek sorunun indeksi
  /// @param question - Yeni soru nesnesi
  static Future<void> updateQuestion(int index, Question question) async {
    await _questionBox.putAt(index, question);
  }

  /// Bir soruyu siler
  /// @param index - Silinecek sorunun indeksi
  static Future<void> deleteQuestion(int index) async {
    await _questionBox.deleteAt(index);
  }

  /// Tüm soruları getirir
  /// Filtreleme olmadan veritabanındaki tüm soruları listeler
  static List<Question> getAllQuestions() {
    return _questionBox.values.toList();
  }

  /// Derslere göre soru sayısını hesaplar
  /// Her dersin toplam soru sayısını içeren bir map döndürür
  static Map<String, int> getQuestionCountBySubject() {
    final Map<String, int> counts = {};
    for (var question in _questionBox.values) {
      counts[question.subject] = (counts[question.subject] ?? 0) + 1;
    }
    return counts;
  }

  /// Sınıflara göre soru sayısını hesaplar
  /// Her sınıf seviyesinin toplam soru sayısını içeren bir map döndürür
  static Map<int, int> getQuestionCountByGrade() {
    final Map<int, int> counts = {};
    for (var question in _questionBox.values) {
      counts[question.grade] = (counts[question.grade] ?? 0) + 1;
    }
    return counts;
  }

  /// Veritabanı bağlantısını kapatır
  /// Uygulama kapanırken çağrılmalıdır
  static Future<void> close() async {
    await _questionBox.close();
  }

  /// Tüm verileri temizler
  /// Test ve debug amaçlı kullanılır
  static Future<void> clearAllData() async {
    await _questionBox.clear();
  }

  /// Örnek verileri yeniden yükler
  /// Test ve demo amaçlı kullanılır
  static Future<void> reloadSampleData() async {
    await _questionBox.clear();
    await _loadInitialQuestions();
  }
}
