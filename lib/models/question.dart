import 'package:hive/hive.dart';

part 'question.g.dart';

/// Soru modeli
/// Hive veritabanı ile uyumlu çalışacak şekilde tasarlanmıştır
@HiveType(typeId: 0)
class Question extends HiveObject {
  /// Sorunun metni
  @HiveField(0)
  final String questionText;

  /// Cevap seçenekleri
  @HiveField(1)
  final List<String> options;

  /// Doğru cevabın indeksi (0-based)
  @HiveField(2)
  final int correctAnswerIndex;

  /// Sorunun ait olduğu ders
  @HiveField(3)
  final String subject;

  /// Sorunun hedef sınıf seviyesi
  @HiveField(4)
  final int grade;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.subject,
    required this.grade,
  });
}
