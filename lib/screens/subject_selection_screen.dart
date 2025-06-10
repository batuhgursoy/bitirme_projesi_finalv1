import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/quiz_controller.dart';
import 'grade_selection_screen.dart';

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.8);
  
  final List<Map<String, dynamic>> subjects = [
    {
      'title': 'Türkçe',
      'description': 'Dilbilgisi ve okuma anlama',
      'color': const Color(0xFFFFA726),
      'icon': Icons.menu_book,
      'pattern': 'assets/images/turkish_pattern.png',
      'background': 'assets/images/book.png',
    },
    {
      'title': 'Matematik',
      'description': 'Sayılar ve problem çözme',
      'color': const Color(0xFF7C4DFF),
      'icon': Icons.calculate,
      'pattern': 'assets/images/math_pattern.png',
      'background': 'assets/images/math.png',
    },
    {
      'title': 'Hayat Bilgisi',
      'description': 'Çevre ve günlük hayat',
      'color': const Color(0xFF4CAF50),
      'icon': Icons.nature_people,
      'pattern': 'assets/images/science_pattern.png',
      'background': 'assets/images/science.png',
    },
    {
      'title': 'İngilizce',
      'description': 'Kelimeler ve basit cümleler',
      'color': const Color(0xFF42A5F5),
      'icon': Icons.language,
      'pattern': 'assets/images/english_pattern.png',
      'background': 'assets/images/language.png',
    },
  ];
  
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Görüntülenen ders kartının rengini tema olarak kullan
    final Color currentSubjectColor = subjects[_currentIndex]['color'] as Color;

    return GetBuilder<QuizController>(
      init: Get.find<QuizController>(),
      builder: (controller) {
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
                      currentSubjectColor.withOpacity(0.1),
                      Colors.white,
                    ],
                  ),
                ),
              ),
              
              // Background floating bubbles
              ...List.generate(10, (index) {
                final random = Random();
                final size = 20.0 + random.nextDouble() * 40;
                final color = currentSubjectColor;
                
                return Positioned(
                  top: random.nextDouble() * MediaQuery.of(context).size.height,
                  left: random.nextDouble() * MediaQuery.of(context).size.width,
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(seconds: 5 + random.nextInt(10)),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(
                          sin(value * 2 * pi) * 30,
                          cos(value * 2 * pi) * 30,
                        ),
                        child: Opacity(
                          opacity: 0.2,
                          child: Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
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
                    // Custom App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black54),
                            onPressed: () => Get.back(),
                          ),
                          const Spacer(),
                          // Logo element
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
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade300,
                                    Colors.purple.shade300,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.shade200.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.school_rounded, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'İlkokul Quiz',
                                    style: TextStyle(
                                      color: Colors.white,
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
                          clipBehavior: Clip.none,
                          children: [
                            // Multiple floating decorative elements
                            ...List.generate(3, (index) {
                              // Seçilen dersin ikonunu opak yansımalar olarak göster
                              final IconData subjectIcon = subjects[_currentIndex]['icon'] as IconData;
                              final offset = index * 0.5;
                              return Positioned(
                                right: 30 - (index * 10),
                                top: 5 + (index * 15),
                                child: TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: Duration(milliseconds: 1000 + (index * 200)),
                                  curve: Curves.easeOutBack,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Transform.rotate(
                                        angle: 0.1 * index,
                                        child: Opacity(
                                          opacity: 0.15,
                                          child: Icon(
                                            subjectIcon,
                                            size: 60 - (index * 5),
                                            color: currentSubjectColor,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }),
                            
                            // Accent line with current subject color
                            Positioned(
                              top: 26,
                              right: -20,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 1200),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Container(
                                      height: 8,
                                      width: 100 * value,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            currentSubjectColor.withOpacity(0.5),
                                            currentSubjectColor,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            
                            // Title content
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Main title with 3D effect and current color
                                Stack(
                                  children: [
                                    // Shadow text (3D effect)
                                    Text(
                                      'Dersler',
                                      style: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Nunito',
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 6
                                          ..color = Colors.grey.shade200,
                                      ),
                                    ),
                                    
                                    // Color text on top
                                    ShaderMask(
                                      blendMode: BlendMode.srcIn,
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          colors: [
                                            currentSubjectColor.withOpacity(0.9),
                                            HSLColor.fromColor(currentSubjectColor)
                                                .withLightness(
                                                  (HSLColor.fromColor(currentSubjectColor).lightness - 0.2)
                                                      .clamp(0.0, 1.0))
                                                .toColor(),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds);
                                      },
                                      child: const Text(
                                        'Dersler',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Nunito',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // Animated underline with current subject color
                                TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, child) {
                                    return Container(
                                      height: 4,
                                      width: 150 * value,
                                      margin: const EdgeInsets.only(top: 5),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            currentSubjectColor,
                                            HSLColor.fromColor(currentSubjectColor)
                                                .withLightness(
                                                  (HSLColor.fromColor(currentSubjectColor).lightness - 0.2)
                                                      .clamp(0.0, 1.0))
                                                .toColor(),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: currentSubjectColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                
                                const SizedBox(height: 14),
                                
                                // Animated subtitle with typing effect
                                Obx(() {
                                  final bool showDefaultText = subjects[_currentIndex]['title'] == controller.selectedSubject.value && 
                                                              subjects[_currentIndex]['title'] != 'Hayat Bilgisi' &&
                                                              subjects[_currentIndex]['title'] != 'Matematik';
                                  // Always use "[Subject] dersini seçmek için dokun" format for every subject
                                  final String displayText = '${subjects[_currentIndex]['title']} dersini seçmek için dokun';
                                  
                                  return DefaultTextStyle(
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: currentSubjectColor.withOpacity(0.8),
                                      fontFamily: 'Nunito',
                                      letterSpacing: 0.6,
                                      height: 1.2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0, end: 1),
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeOut,
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: Text(displayText),
                                        );
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // 3D Carousel for subjects
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: subjects.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          final color = subject['color'] as Color;
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
                                    controller.selectSubject(subject['title'] as String);
                                    Get.to(() => const GradeSelectionScreen());
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
                                            subject['pattern'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(color: color.withOpacity(0.05));
                                            },
                                          ),
                                        ),
                                      ),
                                      
                                      // Content
                                      Container(
                                        padding: const EdgeInsets.all(30),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            // Icon with glow
                                            Transform.rotate(
                                              angle: active ? 0.05 : 0,
                                              child: Container(
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
                                                  child: Image.asset(
                                                    subject['background'],
                                                    width: 70,
                                                    height: 70,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Icon(
                                                        subject['icon'],
                                                        size: 60,
                                                        color: color,
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            const SizedBox(height: 20),
                                            
                                            // Title and description
                                            Column(
                                              children: [
                                                Text(
                                                  subject['title'],
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                    color: color,
                                                    fontFamily: 'Nunito',
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  subject['description'],
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
                                                  child: const Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        'Başla',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Icon(
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
                    
                    // Carousel indicators
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          subjects.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == index ? 16 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? subjects[index]['color']
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
      },
    );
  }
} 