import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ParticleModel {
  Offset position;
  Color color;
  double speed;
  double radius;
  double direction;

  ParticleModel({
    required this.position,
    required this.color,
    required this.speed,
    required this.radius,
    required this.direction,
  });

  void update(Size size) {
    position = Offset(
      position.dx + cos(direction) * speed,
      position.dy + sin(direction) * speed,
    );

    if (position.dx < 0 || position.dx > size.width) {
      direction = pi - direction;
    }
    if (position.dy < 0 || position.dy > size.height) {
      direction = -direction;
    }
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final List<ParticleModel> particles = [];
  final Random random = Random();
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initParticles();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initParticles() {
    for (int i = 0; i < 20; i++) {
      particles.add(
        ParticleModel(
          position: Offset(random.nextDouble() * Get.width,
              random.nextDouble() * Get.height),
          color: Color.fromRGBO(random.nextInt(255), random.nextInt(255),
              random.nextInt(255), 0.7),
          speed: 1 + random.nextDouble() * 2,
          radius: 4 + random.nextDouble() * 6,
          direction: random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background with particles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              for (var particle in particles) {
                particle.update(size);
              }
              return CustomPaint(
                size: Size.infinite,
                painter: ParticlePainter(particles: particles),
              );
            },
          ),

          // Wave container at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(size.width, size.height * 0.5),
              painter: WavePainter(),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 1),

                  // Main content with animated scale
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Center(
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(0.1)
                          ..rotateY(-0.1),
                        alignment: Alignment.center,
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.orange.shade300,
                                      Colors.purple.shade300,
                                      Colors.blue.shade300,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.school_rounded,
                                  size: 64,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'İlkokul Quiz',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Öğrenmek Eğlenceli!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 1),

                  // Start button
                  Center(
                    child: GestureDetector(
                      onTap: () => Get.toNamed('/subject-selection'),
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          double bounceValue =
                              sin(_controller.value * 3 * pi) * 0.05;
                          return Transform.scale(
                            scale: 1.0 + bounceValue,
                            child: Container(
                              width: 180,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade700,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Başla',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<ParticleModel> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blue.shade300,
          Colors.blue.shade500,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();

    // Start from bottom left
    path.moveTo(0, size.height);

    // First wave
    path.quadraticBezierTo(size.width * 0.25, size.height - 80,
        size.width * 0.5, size.height - 40);

    // Second wave
    path.quadraticBezierTo(
        size.width * 0.75, size.height, size.width, size.height - 60);

    // Connect to bottom right
    path.lineTo(size.width, size.height);

    // Close the path
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
