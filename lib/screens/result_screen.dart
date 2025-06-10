import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import 'welcome_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<Color> _confettiColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
  ];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.find<QuizController>();
    final correctAnswers = controller.correctAnswers;
    final totalQuestions = controller.questions.length;
    final score = (correctAnswers / totalQuestions) * 100;

    // Get subject color theme
    final Color subjectColor =
        _getSubjectColor(controller.selectedSubject.value);
    final Color lightSubjectColor =
        _getSubjectColorLight(controller.selectedSubject.value);

    // Determine achievement level
    String achievementText = '';
    Icon achievementIcon = const Icon(Icons.star, color: Colors.amber);
    double animationValue = 0.0;

    if (score >= 90) {
      achievementText = 'Olağanüstü!';
      achievementIcon =
          const Icon(Icons.emoji_events, color: Colors.amber, size: 48);
      animationValue = 1.0;
    } else if (score >= 70) {
      achievementText = 'Çok İyi!';
      achievementIcon = const Icon(Icons.stars, color: Colors.amber, size: 40);
      animationValue = 0.8;
    } else if (score >= 50) {
      achievementText = 'İyi!';
      achievementIcon = const Icon(Icons.star, color: Colors.amber, size: 36);
      animationValue = 0.6;
    } else {
      achievementText = 'Tekrar Deneyebilirsin';
      achievementIcon =
          const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 32);
      animationValue = 0.3;
    }

    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lightSubjectColor,
                  Colors.white,
                ],
              ),
            ),
          ),

          // Confetti animation for high scores
          if (score >= 70)
            ...List.generate(100, (index) {
              final size = _random.nextDouble() * 12 + 4;
              final initialPosition =
                  _random.nextDouble() * MediaQuery.of(context).size.width;
              final color =
                  _confettiColors[_random.nextInt(_confettiColors.length)];
              final delay = _random.nextDouble() * 1.0;

              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final animationValue =
                      (_animationController.value - delay).clamp(0.0, 1.0);
                  final y = animationValue * MediaQuery.of(context).size.height;
                  final x = initialPosition + 30 * sin(animationValue * 10);
                  final opacity = (1.0 - animationValue).clamp(0.0, 1.0);

                  return Positioned(
                    left: x,
                    top: y,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.rotate(
                        angle: animationValue * 10,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: color,
                            shape: _random.nextBool()
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Custom app bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            Icons.home_rounded,
                            color: subjectColor,
                          ),
                          onPressed: () =>
                              Get.offAll(() => const WelcomeScreen()),
                        ),
                      ),
                      const Spacer(),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value.clamp(0.0, 1.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    subjectColor,
                                    HSLColor.fromColor(subjectColor)
                                        .withLightness(
                                            (HSLColor.fromColor(subjectColor)
                                                        .lightness +
                                                    0.15)
                                                .clamp(0.0, 1.0))
                                        .toColor(),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: subjectColor.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                controller.selectedSubject.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Title with animation
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value.clamp(0.0, 1.0))),
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: Column(
                              children: [
                                Text(
                                  'Quiz Tamamlandı!',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    foreground: Paint()
                                      ..shader = LinearGradient(
                                        colors: [
                                          subjectColor,
                                          HSLColor.fromColor(subjectColor)
                                              .withLightness(
                                                  (HSLColor.fromColor(
                                                                  subjectColor)
                                                              .lightness +
                                                          0.2)
                                                      .clamp(0.0, 1.0))
                                              .toColor(),
                                        ],
                                      ).createShader(const Rect.fromLTWH(
                                          0.0, 0.0, 200.0, 70.0)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                achievementIcon,
                                const SizedBox(height: 8),
                                Text(
                                  achievementText,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: subjectColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Animated progress indicator
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 16.0),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    builder: (context, animation, child) {
                      return Column(
                        children: [
                          // Score display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(score * animation).toInt()}%',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: subjectColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Skorun',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  Text(
                                    '$correctAnswers / $totalQuestions',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Progress bar
                          Stack(
                            children: [
                              // Background
                              Container(
                                height: 24,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              // Foreground
                              Container(
                                height: 24,
                                width: MediaQuery.of(context).size.width *
                                    (correctAnswers / totalQuestions) *
                                    animation,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      subjectColor,
                                      HSLColor.fromColor(subjectColor)
                                          .withLightness(
                                              (HSLColor.fromColor(subjectColor)
                                                          .lightness +
                                                      0.15)
                                                  .clamp(0.0, 1.0))
                                          .toColor(),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: subjectColor.withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Statistics
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatisticCard(
                          'Doğru',
                          correctAnswers,
                          Icons.check_circle_rounded,
                          Colors.green,
                          subjectColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatisticCard(
                          'Yanlış',
                          totalQuestions - correctAnswers,
                          Icons.cancel_rounded,
                          Colors.red,
                          subjectColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Expandable question analysis section
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.15,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle for dragging
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Soru Analizi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: subjectColor,
                        ),
                      ),
                    ),

                    // Instructions
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 4.0),
                      child: Text(
                        'Daha fazla soru görmek için yukarı kaydırın',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Question list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.questions.length,
                        itemBuilder: (context, index) {
                          final question = controller.questions[index];
                          final userAnswer =
                              index < controller.userAnswers.length
                                  ? controller.userAnswers[index]
                                  : -1;
                          final isCorrect =
                              userAnswer == question.correctAnswerIndex;

                          final userSelectedOption = userAnswer >= 0 &&
                                  userAnswer < question.options.length
                              ? question.options[userAnswer]
                              : "Cevapsız";

                          final correctOption =
                              question.options[question.correctAnswerIndex];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Question header
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? Colors.green.shade50
                                        : Colors.red.shade50,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    border: Border.all(
                                      color: isCorrect
                                          ? Colors.green.shade200
                                          : Colors.red.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 14,
                                        backgroundColor: isCorrect
                                            ? Colors.green.shade100
                                            : Colors.red.shade100,
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: isCorrect
                                                ? Colors.green.shade800
                                                : Colors.red.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        isCorrect
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: isCorrect
                                            ? Colors.green
                                            : Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isCorrect ? 'Doğru' : 'Yanlış',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isCorrect
                                              ? Colors.green.shade700
                                              : Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Question text
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    question.questionText,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // Divider
                                Divider(height: 1, color: Colors.grey.shade200),

                                // Answers - Made wider and more prominent
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // User answer
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                isCorrect
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                color: isCorrect
                                                    ? Colors.green
                                                    : Colors.red,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Senin Cevabın:',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(
                                                top: 6, bottom: 8),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 12),
                                            decoration: BoxDecoration(
                                              color: isCorrect
                                                  ? Colors.green.shade50
                                                  : Colors.red.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isCorrect
                                                    ? Colors.green.shade200
                                                    : Colors.red.shade200,
                                              ),
                                            ),
                                            child: Text(
                                              userSelectedOption,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: isCorrect
                                                    ? Colors.green.shade800
                                                    : Colors.red.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (!isCorrect) ...[
                                        // Correct answer
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Doğru Cevap:',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade700,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              width: double.infinity,
                                              margin:
                                                  const EdgeInsets.only(top: 6),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.green.shade200,
                                                ),
                                              ),
                                              child: Text(
                                                correctOption,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.green.shade800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => Get.offAll(() => const WelcomeScreen()),
          style: ElevatedButton.styleFrom(
            backgroundColor: subjectColor,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_rounded),
              SizedBox(width: 8),
              Text(
                'Ana Menüye Dön',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticCard(String title, int value, IconData icon,
      Color iconColor, Color subjectColor) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: subjectColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Türkçe':
        return const Color(0xFFFFA726); // Turuncu
      case 'Matematik':
        return const Color(0xFF7C4DFF); // Mor
      case 'Hayat Bilgisi':
        return const Color(0xFF4CAF50); // Yeşil
      case 'İngilizce':
        return const Color(0xFF42A5F5); // Mavi
      default:
        return const Color(0xFF156DB4); // Varsayılan mavi
    }
  }

  Color _getSubjectColorLight(String subject) {
    switch (subject) {
      case 'Türkçe':
        return const Color(0xFFFFE0B2); // Açık turuncu
      case 'Matematik':
        return const Color(0xFFE1D4FF); // Açık mor
      case 'Hayat Bilgisi':
        return const Color(0xFFDCEDC8); // Açık yeşil
      case 'İngilizce':
        return const Color(0xFFBBDEFB); // Açık mavi
      default:
        return const Color(0xFFCFE9FC); // Varsayılan açık mavi
    }
  }
}
