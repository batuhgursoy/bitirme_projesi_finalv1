import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import 'quiz_screen.dart';
import 'dart:math';

class GradeSelectionScreen extends StatefulWidget {
  const GradeSelectionScreen({super.key});

  @override
  State<GradeSelectionScreen> createState() => _GradeSelectionScreenState();
}

class _GradeSelectionScreenState extends State<GradeSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.8);
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _controller.forward();
    
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentIndex != next) {
        setState(() {
          _currentIndex = next;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Subject rengi üzerinden sınıf rengi oluşturan yardımcı fonksiyon
  Color _getGradeColorVariation(Color baseColor, int grade) {
    final hslColor = HSLColor.fromColor(baseColor);
    
    switch(grade) {
      case 1:
        // Daha canlı/açık ton
        return hslColor.withLightness((hslColor.lightness + 0.1).clamp(0.0, 1.0))
                      .withSaturation((hslColor.saturation + 0.1).clamp(0.0, 1.0))
                      .toColor();
      case 2:
        // Orijinal tona yakın
        return hslColor.toColor();
      case 3:
        // Biraz daha koyu ton
        return hslColor.withLightness((hslColor.lightness - 0.1).clamp(0.0, 1.0))
                      .toColor();
      case 4:
        // En koyu ton
        return hslColor.withLightness((hslColor.lightness - 0.2).clamp(0.0, 1.0))
                      .withSaturation((hslColor.saturation + 0.05).clamp(0.0, 1.0))
                      .toColor();
      default:
        return baseColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final QuizController controller = Get.find<QuizController>();
    final size = MediaQuery.of(context).size;
    final subjectColor = _getSubjectColor(controller.selectedSubject.value);
    
    // Sınıf listesini her build işleminde dinamik olarak oluşturalım
    final List<Map<String, dynamic>> dynamicGrades = [
      {
        'grade': 1,
        'description': '1. Sınıf temel konuları',
        'color': _getGradeColorVariation(subjectColor, 1),
        'icon': Icons.looks_one_rounded,
        'pattern': 'assets/images/grade1_pattern.png',
      },
      {
        'grade': 2,
        'description': '2. Sınıf orta düzey konuları',
        'color': _getGradeColorVariation(subjectColor, 2),
        'icon': Icons.looks_two_rounded,
        'pattern': 'assets/images/grade2_pattern.png',
      },
      {
        'grade': 3,
        'description': '3. Sınıf ileri düzey konuları',
        'color': _getGradeColorVariation(subjectColor, 3),
        'icon': Icons.looks_3_rounded,
        'pattern': 'assets/images/grade3_pattern.png',
      },
      {
        'grade': 4,
        'description': '4. Sınıf kapsamlı konuları',
        'color': _getGradeColorVariation(subjectColor, 4),
        'icon': Icons.looks_4_rounded,
        'pattern': 'assets/images/grade4_pattern.png',
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  subjectColor.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
          ),
          
          // Background floating elements
          ...List.generate(8, (index) {
            final random = Random();
            final size = 20.0 + random.nextDouble() * 30;
            final double top = random.nextDouble() * MediaQuery.of(context).size.height;
            final double left = random.nextDouble() * MediaQuery.of(context).size.width;
            
            return Positioned(
              top: top,
              left: left,
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(seconds: 5 + random.nextInt(8)),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(
                      sin(value * 2 * pi) * 20,
                      cos(value * 2 * pi) * 20,
                    ),
                    child: Opacity(
                      opacity: 0.2,
                      child: Icon(
                        _getSubjectIcon(controller.selectedSubject.value),
                        size: size,
                        color: subjectColor,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                // App Bar Başlık
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54),
                        onPressed: () => Get.back(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 22,
                      ),
                      const Spacer(),
                      // Logo element with selected subject
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: subjectColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getSubjectIcon(controller.selectedSubject.value),
                                color: subjectColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                controller.selectedSubject.value,
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Title section
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Stack(
                      children: [
                        // Decorative elements - subject-specific icon
                        Positioned(
                          right: 0,
                          top: 10,
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                colors: [
                                  subjectColor.withOpacity(0.2),
                                  subjectColor.withOpacity(0.08),
                                ],
                              ).createShader(bounds);
                            },
                            child: Icon(
                              _getSubjectIcon(controller.selectedSubject.value),
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        // Title content
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Main title with gradient and shadow based on subject color
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  colors: [
                                    subjectColor,
                                    _getGradeColorVariation(subjectColor, 4),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds);
                              },
                              child: const Text(
                                'Sınıf Seçimi',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Nunito',
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Animated underline with subject color
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return Container(
                                  height: 3,
                                  width: 120 * value,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        subjectColor,
                                        _getGradeColorVariation(subjectColor, 4),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 10),
                            
                            // Subtitle with fade in animation
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutQuad,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Text(
                                    'Hangi sınıf seviyesinde ${controller.selectedSubject.value} soruları çözmek istersin?',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                      fontFamily: 'Nunito',
                                      letterSpacing: 0.5,
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
                
                // 3D Carousel for grades
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: dynamicGrades.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final grade = dynamicGrades[index];
                      final color = grade['color'] as Color;
                      bool active = _currentIndex == index;
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutQuint,
                        margin: EdgeInsets.only(
                          top: active ? 20 : 40,
                          bottom: active ? 20 : 40,
                          left: 10,
                          right: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(active ? 0.4 : 0.1),
                              blurRadius: active ? 30 : 10,
                              spreadRadius: active ? 5 : 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                controller.selectGrade(grade['grade'] as int);
                                controller.loadQuestions();
                                Get.to(() => const QuizScreen());
                              },
                              splashColor: color.withOpacity(0.2),
                              highlightColor: Colors.transparent,
                              child: Stack(
                                children: [
                                  // Background pattern
                                  Positioned.fill(
                                    child: Opacity(
                                      opacity: 0.05,
                                      child: Image.asset(
                                        grade['pattern'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          // Fallback - decorative background with school themes
                                          return CustomPaint(
                                            painter: GradePatternPainter(
                                              color: color,
                                              grade: grade['grade'] as int,
                                            ),
                                            size: Size.infinite,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  
                                  // Gradient overlay
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withOpacity(0),
                                            color.withOpacity(0.15),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Content
                                  Container(
                                    padding: const EdgeInsets.all(30),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // Grade number with glow
                                        Transform.rotate(
                                          angle: active ? 0.05 : 0,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              // Shadow background circle
                                              Container(
                                                width: 140,
                                                height: 140,
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.1),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              
                                              // Main circle
                                              Container(
                                                width: 120,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: color.withOpacity(0.5),
                                                      blurRadius: 20,
                                                      spreadRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    "${grade['grade']}",
                                                    style: TextStyle(
                                                      fontSize: 60,
                                                      fontWeight: FontWeight.bold,
                                                      color: color,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              
                                              // Small animated circles - with position clamping
                                              ...List.generate(3, (i) {
                                                final double angle = 2 * pi * i / 3;
                                                // Calculate position with safe boundaries
                                                final calculatedLeft = 70 + 60 * cos(angle + (_currentIndex == index ? 0.001 * DateTime.now().millisecondsSinceEpoch % (2 * pi) : 0));
                                                final calculatedTop = 70 + 60 * sin(angle + (_currentIndex == index ? 0.001 * DateTime.now().millisecondsSinceEpoch % (2 * pi) : 0));
                                                
                                                // Clamp values to stay within container bounds
                                                final safeLeft = calculatedLeft.clamp(10.0, 130.0);
                                                final safeTop = calculatedTop.clamp(10.0, 130.0);
                                                
                                                return Positioned(
                                                  left: safeLeft,
                                                  top: safeTop,
                                                  child: Container(
                                                    width: 16,
                                                    height: 16,
                                                    decoration: BoxDecoration(
                                                      color: color.withOpacity(0.7),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 20),
                                        
                                        // Grade title and description
                                        Column(
                                          children: [
                                            Text(
                                              "${grade['grade']}. Sınıf",
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: color,
                                                fontFamily: 'Nunito',
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              grade['description'] as String,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 20),
                                        
                                        // Action button
                                        Transform.translate(
                                          offset: Offset(0, active ? 0 : 20),
                                          child: AnimatedOpacity(
                                            duration: const Duration(milliseconds: 500),
                                            opacity: active ? 1.0 : 0.0,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius: BorderRadius.circular(30),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: color.withOpacity(0.4),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Quize Başla',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.arrow_forward_rounded,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Carousel indicators - with bottom padding for safety
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      dynamicGrades.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? dynamicGrades[index]['color']
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getSubjectColor(String subject) {
    switch(subject) {
      case 'Türkçe':
        return const Color(0xFFFFA726);  // Turuncu
      case 'Matematik':
        return const Color(0xFF7C4DFF);  // Mor
      case 'Hayat Bilgisi':
        return const Color(0xFF4CAF50);  // Yeşil
      case 'İngilizce':
        return const Color(0xFF42A5F5);  // Mavi
      default:
        return const Color(0xFFFFA726);  // Varsayılan: Turuncu
    }
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
        return Icons.school_rounded;
    }
  }
}

class GradePatternPainter extends CustomPainter {
  final Color color;
  final int grade;
  
  GradePatternPainter({required this.color, required this.grade});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    final symbolPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw random educational symbols
    final random = Random(grade); // Use grade as seed for consistent randomness
    
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final symbolSize = 10.0 + random.nextDouble() * 20;
      
      // Different symbols based on grade
      switch (grade) {
        case 1:
          // Simple shapes for 1st grade
          if (i % 3 == 0) {
            // Circle
            canvas.drawCircle(Offset(x, y), symbolSize, symbolPaint);
          } else if (i % 3 == 1) {
            // Square
            canvas.drawRect(
              Rect.fromCenter(center: Offset(x, y), width: symbolSize * 2, height: symbolSize * 2),
              symbolPaint
            );
          } else {
            // Triangle
            final path = Path();
            path.moveTo(x, y - symbolSize);
            path.lineTo(x - symbolSize, y + symbolSize);
            path.lineTo(x + symbolSize, y + symbolSize);
            path.close();
            canvas.drawPath(path, symbolPaint);
          }
          break;
          
        case 2:
          // Numbers for 2nd grade
          if (i % 4 == 0) {
            // Plus sign
            canvas.drawLine(
              Offset(x - symbolSize, y),
              Offset(x + symbolSize, y),
              symbolPaint
            );
            canvas.drawLine(
              Offset(x, y - symbolSize),
              Offset(x, y + symbolSize),
              symbolPaint
            );
          } else {
            // Circle with number
            canvas.drawCircle(Offset(x, y), symbolSize, symbolPaint);
          }
          break;
          
        case 3:
          // More complex symbols for 3rd grade
          if (i % 3 == 0) {
            // Star shape
            final path = Path();
            for (int j = 0; j < 5; j++) {
              final angle = -pi / 2 + j * 2 * pi / 5;
              final innerAngle = angle + pi / 5;
              
              if (j == 0) {
                path.moveTo(
                  x + cos(angle) * symbolSize,
                  y + sin(angle) * symbolSize
                );
              } else {
                path.lineTo(
                  x + cos(angle) * symbolSize,
                  y + sin(angle) * symbolSize
                );
              }
              
              path.lineTo(
                x + cos(innerAngle) * (symbolSize / 2),
                y + sin(innerAngle) * (symbolSize / 2)
              );
            }
            path.close();
            canvas.drawPath(path, symbolPaint);
          } else {
            // Wave line
            final path = Path();
            path.moveTo(x - symbolSize, y);
            for (int j = 0; j < 4; j++) {
              final waveX = x - symbolSize + j * symbolSize / 2;
              final waveY = y + (j % 2 == 0 ? -1 : 1) * symbolSize / 2;
              path.lineTo(waveX, waveY);
            }
            canvas.drawPath(path, symbolPaint);
          }
          break;
          
        case 4:
          // More educational symbols for 4th grade
          if (i % 3 == 0) {
            // Compass or clock shape
            canvas.drawCircle(Offset(x, y), symbolSize, symbolPaint);
            canvas.drawLine(
              Offset(x, y),
              Offset(x + cos(pi/4) * symbolSize, y + sin(pi/4) * symbolSize),
              symbolPaint..strokeWidth = 3
            );
            canvas.drawLine(
              Offset(x, y),
              Offset(x + cos(3*pi/4) * symbolSize * 0.6, y + sin(3*pi/4) * symbolSize * 0.6),
              symbolPaint..strokeWidth = 3
            );
          } else if (i % 3 == 1) {
            // Molecule or atom shape
            canvas.drawCircle(Offset(x, y), symbolSize / 3, symbolPaint);
            for (int j = 0; j < 3; j++) {
              final angle = j * 2 * pi / 3;
              final orbitX = x + cos(angle) * symbolSize;
              final orbitY = y + sin(angle) * symbolSize;
              canvas.drawCircle(Offset(orbitX, orbitY), symbolSize / 5, symbolPaint);
              canvas.drawLine(Offset(x, y), Offset(orbitX, orbitY), symbolPaint);
            }
          } else {
            // Graph or chart
            final rect = Rect.fromCenter(center: Offset(x, y), width: symbolSize * 2, height: symbolSize * 2);
            canvas.drawRect(rect, symbolPaint);
            canvas.drawLine(
              Offset(rect.left, rect.bottom),
              Offset(rect.right, rect.top),
              symbolPaint
            );
          }
          break;
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 