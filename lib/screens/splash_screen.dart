import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Loop the pulse effect after the entry animation completes
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat(reverse: true);
      }
    });

    // Navigate to onboarding screen after 3 seconds
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF), // Soft white
              Color(0xFFF8FAFC), // Off-white/slate
              Color(0xFFF1F5F9), // Light grey
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Subtle background ambient glows (soft pastel colors for white theme)
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.08),
                        blurRadius: 100,
                        spreadRadius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F2FE).withOpacity(0.06),
                        blurRadius: 80,
                        spreadRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Core content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _opacityAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C63FF).withOpacity(0.18),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: CustomPaint(
                          painter: LogoPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // App Name
                    const Text(
                      'SingleMart',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1B4B), // Deep indigo/charcoal
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Color(0x1F6C63FF),
                            offset: Offset(0, 4),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Subtitle
                    const Text(
                      'Your Unified Local Marketplace',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B), // Slate grey
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Shimmer progress loader at the bottom
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 180,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: const LinearProgressIndicator(
                            minHeight: 4,
                            backgroundColor: Color(0xFFE2E8F0), // Light track
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Loading Experience...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8), // Mid slate grey
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for a stunning e-commerce cart + infinity logo
class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Draw outer neon border
    paint.shader = const LinearGradient(
      colors: [Color(0xFF6C63FF), Color(0xFF00F2FE)],
    ).createShader(rect);
    
    canvas.drawArc(
      rect.deflate(10),
      0,
      6.28, // Complete circle
      false,
      paint,
    );

    // Inner stylized 'S' + Shop Bag icon
    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    innerPaint.shader = const LinearGradient(
      colors: [Color(0xFF00F2FE), Color(0xFF6C63FF)],
    ).createShader(rect);

    // Drawing shopping bag contour inside
    final path = Path();
    // Top handle
    path.addArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 - 10),
        width: 30,
        height: 25,
      ),
      3.14,
      3.14,
    );
    
    // Bag body
    path.moveTo(size.width / 2 - 22, size.height / 2 - 10);
    path.lineTo(size.width / 2 + 22, size.height / 2 - 10);
    path.lineTo(size.width / 2 + 18, size.height / 2 + 25);
    path.quadraticBezierTo(
      size.width / 2,
      size.height / 2 + 30,
      size.width / 2 - 18,
      size.height / 2 + 25,
    );
    path.close();

    canvas.drawPath(path, innerPaint);
    
    // Glowing dot in the center representing local store
    final dotPaint = Paint()
      ..color = const Color(0xFF00F2FE)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(size.width / 2, size.height / 2 + 5), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
