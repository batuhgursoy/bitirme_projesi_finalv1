import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import '../models/question.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final Color subjectColor;
  final Function(int) onAnswerSelected;

  const QuestionCard({
    super.key,
    required this.question,
    required this.subjectColor,
    required this.onAnswerSelected,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> with SingleTickerProviderStateMixin {
  final QuizController controller = Get.find<QuizController>();
  late AnimationController _animationController;
  late Animation<double> _questionAnimation;
  
  int? selectedAnswerIndex;
  bool isAnswered = false;
  final List<GlobalKey> _optionKeys = List.generate(4, (_) => GlobalKey());
  final List<bool> _optionHovered = List.generate(4, (_) => false);
  final List<double> _confettiPositions = List.generate(15, (_) => Random().nextDouble() * 2 - 1);
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _questionAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack,
    );
    
    _animationController.forward();
  }
  
  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question != widget.question) {
      setState(() {
        isAnswered = false;
        selectedAnswerIndex = null;
        // Remove animation restart between questions
        // _animationController.reset();
        // _animationController.forward();
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Animated background particles based on subject color
        ...List.generate(10, (index) {
          final random = Random();
          final size = 10.0 + random.nextDouble() * 30;
          final speed = 1.0 + random.nextDouble() * 3;
          final color = HSLColor.fromColor(widget.subjectColor)
              .withLightness((HSLColor.fromColor(widget.subjectColor).lightness + 0.2).clamp(0.0, 1.0))
              .toColor()
              .withOpacity(0.1 + random.nextDouble() * 0.1);
          
          return Positioned(
            left: random.nextDouble() * MediaQuery.of(context).size.width,
            top: random.nextDouble() * MediaQuery.of(context).size.height,
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(seconds: (5 * speed).round()),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(
                    sin(value * 2 * pi) * 30,
                    cos(value * 2 * pi) * 30 + value * 100,
                  ),
                  child: Opacity(
                    opacity: 0.7 - (value * 0.7),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: color,
                        shape: index % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                        borderRadius: index % 2 == 0 ? null : BorderRadius.circular(5),
                      ),
                    ),
                  ),
                );
              },
              onEnd: () {
                // Rebuild to restart animation
                if (mounted) setState(() {});
              },
            ),
          );
        }),
      
        SafeArea(
          child: Column(
            children: [
              // Progress bar and navigation
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Back button with animated ripple
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.subjectColor.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: widget.subjectColor,
                          size: 20,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Progress indicator
                    Obx(() {
                      final currentIndex = controller.currentQuestionIndex.value;
                      final totalQuestions = controller.questions.length;
                      
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: widget.subjectColor.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            totalQuestions,
                            (index) {
                              final bool isCurrent = index == currentIndex;
                              final bool isPast = index < currentIndex;
                              
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                child: Icon(
                                  isPast ? Icons.star : isCurrent ? Icons.star : Icons.star_border,
                                  color: isPast 
                                      ? widget.subjectColor 
                                      : isCurrent 
                                          ? widget.subjectColor 
                                          : Colors.grey.shade300,
                                  size: isCurrent ? 24 : 18,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Question card with 3D effect
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Animated question card
                    ScaleTransition(
                      scale: _questionAnimation,
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(0.05),
                        alignment: Alignment.center,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                HSLColor.fromColor(widget.subjectColor)
                                    .withLightness(0.95)
                                    .toColor(),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: widget.subjectColor.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Subject icon with glow effect
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: widget.subjectColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: widget.subjectColor.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getSubjectIcon(widget.question.subject),
                                  color: widget.subjectColor,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Question text with animated underline
                              Column(
                                children: [
                                  Text(
                                    widget.question.questionText,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 1000),
                                    curve: Curves.easeOutQuad,
                                    builder: (context, value, _) {
                                      return Container(
                                        height: 2,
                                        width: 80 * value,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              widget.subjectColor,
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Answer options with 3D hover effect
                    ...List.generate(
                      widget.question.options.length,
                      (index) => AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final double delay = index * 0.2;
                          final double start = 0.3;
                          final double end = 1.0;
                          
                          // Calculate a value between 0-1 with delay for each option
                          final animationValue = (_animationController.value - delay) / (1 - delay);
                          final double opacity = animationValue.clamp(0.0, 1.0);
                          final double scale = start + (end - start) * opacity.clamp(0.0, 1.0);
                          
                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale: scale,
                              child: child,
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: isAnswered ? null : () {
                            setState(() {
                              selectedAnswerIndex = index;
                              isAnswered = true;
                            });
                            widget.onAnswerSelected(index);
                          },
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _optionHovered[index] = true),
                            onExit: (_) => setState(() => _optionHovered[index] = false),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0.0,
                                end: _optionHovered[index] ? 0.05 : 0.0,
                              ),
                              duration: const Duration(milliseconds: 200),
                              builder: (context, value, child) {
                                return Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateX(value)
                                    ..rotateY(value),
                                  alignment: Alignment.center,
                                  child: Stack(
                                    children: [
                                      // Answer option card
                                      Container(
                                        key: _optionKeys[index],
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: selectedAnswerIndex == index
                                              ? (widget.question.options[widget.question.correctAnswerIndex] == widget.question.options[index]
                                                  ? Colors.green.shade50
                                                  : Colors.red.shade50)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: selectedAnswerIndex == index
                                                ? (widget.question.options[widget.question.correctAnswerIndex] == widget.question.options[index]
                                                    ? Colors.green
                                                    : Colors.red)
                                                : _optionHovered[index]
                                                    ? widget.subjectColor
                                                    : Colors.grey.shade300,
                                            width: selectedAnswerIndex == index || _optionHovered[index] ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (selectedAnswerIndex == index)
                                                  ? (widget.question.options[widget.question.correctAnswerIndex] == widget.question.options[index]
                                                      ? Colors.green.withOpacity(0.2)
                                                      : Colors.red.withOpacity(0.2))
                                                  : _optionHovered[index]
                                                      ? widget.subjectColor.withOpacity(0.2)
                                                      : Colors.black.withOpacity(0.05),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // Option letter in circle
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 300),
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: selectedAnswerIndex == index
                                                    ? (widget.question.options[widget.question.correctAnswerIndex] == widget.question.options[index]
                                                        ? Colors.green
                                                        : Colors.red)
                                                    : _optionHovered[index]
                                                        ? widget.subjectColor
                                                        : widget.subjectColor.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                                boxShadow: _optionHovered[index] || selectedAnswerIndex == index
                                                    ? [
                                                        BoxShadow(
                                                          color: (selectedAnswerIndex == index)
                                                              ? (widget.question.options[widget.question.correctAnswerIndex] == widget.question.options[index]
                                                                  ? Colors.green.withOpacity(0.3)
                                                                  : Colors.red.withOpacity(0.3))
                                                              : widget.subjectColor.withOpacity(0.2),
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 2),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  String.fromCharCode(65 + index), // A, B, C, D
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: (selectedAnswerIndex == index || _optionHovered[index])
                                                        ? Colors.white
                                                        : widget.subjectColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            
                                            // Option text
                                            Expanded(
                                              child: Text(
                                                widget.question.options[index],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: selectedAnswerIndex == index || _optionHovered[index] 
                                                      ? FontWeight.bold 
                                                      : FontWeight.normal,
                                                  color: selectedAnswerIndex == index
                                                      ? (widget.question.options[widget.question.correctAnswerIndex] == widget.question.options[index]
                                                          ? Colors.green.shade800
                                                          : Colors.red.shade800)
                                                      : _optionHovered[index]
                                                          ? widget.subjectColor
                                                          : Colors.black87,
                                                ),
                                              ),
                                            ),
                                            
                                            // Correct/incorrect icon
                                            if (selectedAnswerIndex == index)
                                              ...List.generate(
                                                widget.question.options[widget.question.correctAnswerIndex] == widget.question.options[index] ? 1 : 0,
                                                (_) => TweenAnimationBuilder<double>(
                                                  tween: Tween<double>(begin: 0, end: 1),
                                                  duration: const Duration(milliseconds: 500),
                                                  curve: Curves.elasticOut,
                                                  builder: (context, value, _) {
                                                    return Transform.scale(
                                                      scale: value,
                                                      child: Container(
                                                        padding: const EdgeInsets.all(4),
                                                        decoration: BoxDecoration(
                                                          color: Colors.green.shade50,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.check,
                                                          color: Colors.green,
                                                          size: 28,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            
                                            if (selectedAnswerIndex == index && 
                                                widget.question.options[widget.question.correctAnswerIndex] != widget.question.options[index])
                                              Icon(
                                                Icons.close,
                                                color: Colors.red,
                                                size: 28,
                                              ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Confetti effect for correct answer
                                      if (selectedAnswerIndex == index && 
                                          widget.question.options[widget.question.correctAnswerIndex] == widget.question.options[index])
                                        ...List.generate(_confettiPositions.length, (i) {
                                          return TweenAnimationBuilder<double>(
                                            tween: Tween<double>(begin: 0, end: 1),
                                            duration: Duration(milliseconds: 800 + (i * 50)),
                                            curve: Curves.easeOutQuad,
                                            builder: (context, value, _) {
                                              return Positioned(
                                                left: Random().nextInt(300).toDouble(),
                                                top: (20.0 + (60 * value) + (Random().nextInt(20) - 10)).toDouble(),
                                                child: Opacity(
                                                  opacity: 1 - value.clamp(0.0, 1.0),
                                                  child: Transform.rotate(
                                                    angle: _confettiPositions[i] * 2 * pi * value,
                                                    child: Container(
                                                      width: 8.0 + (Random().nextInt(8).toDouble()),
                                                      height: 8.0 + (Random().nextInt(8).toDouble()),
                                                      decoration: BoxDecoration(
                                                        color: [
                                                          Colors.green,
                                                          Colors.blue,
                                                          Colors.orange,
                                                          Colors.purple,
                                                          Colors.pink,
                                                          Colors.teal,
                                                        ][Random().nextInt(6)],
                                                        shape: Random().nextBool() ? BoxShape.circle : BoxShape.rectangle,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ],
    );
  }
  
  IconData _getSubjectIcon(String subject) {
    switch(subject) {
      case 'Türkçe':
        return Icons.menu_book;
      case 'Matematik':
        return Icons.calculate;
      case 'Hayat Bilgisi':
        return Icons.nature_people;
      case 'İngilizce':
        return Icons.language;
      default:
        return Icons.school;
    }
  }
}