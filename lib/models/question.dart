import 'package:hive/hive.dart';

part 'question.g.dart';

@HiveType(typeId: 0)
class Question extends HiveObject {
  @HiveField(0)
  final String questionText;

  @HiveField(1)
  final List<String> options;

  @HiveField(2)
  final int correctAnswerIndex;

  @HiveField(3)
  final String subject;

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