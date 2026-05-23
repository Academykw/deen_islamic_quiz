import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constant/app_colors.dart';
import '../../core/widgets/geo_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _subController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _subOpacity;

  @override
  void initState() {
    super.initState();

    // Logo: scale up + fade in
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // App name: slide up + fade in
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Subtitle + tagline
    _subController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _subOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subController, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _subController.forward();

    // Navigate to home after splash
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      // Replace with GoRouter redirect in Step 10
      // context.go('/home');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _subController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          const GeoBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo orb ─────────────────────────
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoOpacity,
                    child: _LogoOrb(),
                  ),
                ),

                const SizedBox(height: 32),

                // ── App name ─────────────────────────
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppColors.goldGlow,
                              AppColors.gold,
                              AppColors.goldLight,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: Text(
                            'DEEN IQ',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: AppColors.white,
                              letterSpacing: 12,
                              shadows: [
                                Shadow(
                                  color: AppColors.gold.withOpacity(0.3),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ISLAMIC QUIZ',
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Arabic tagline ───────────────────
                FadeTransition(
                  opacity: _subOpacity,
                  child: Column(
                    children: [
                      const Text(
                        'اختبر علمك الإسلامي',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 24,
                          color: AppColors.goldLight,
                          height: 1.6,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Test your Islamic knowledge',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Loading indicator bottom ──────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _subOpacity,
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.darkBorder,
                      valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'بسم الله الرحمن الرحيم',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      color: AppColors.textMuted,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The hexagonal/circular logo orb with crescent + star
class _LogoOrb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ── Hexagonal Border ─────────────────────────
        CustomPaint(
          size: const Size(120, 120),
          painter: _HexagonPainter(),
        ),

        // ── Crescent & Star ──────────────────────────
        CustomPaint(
          size: const Size(64, 64),
          painter: _CrescentStarPainter(),
        ),
      ],
    );
  }
}

class _CrescentStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.goldGlow, AppColors.gold, AppColors.goldLight],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // ── Crescent ─────────────────────────────────────
    // We create a crescent by subtracting a smaller circle from a larger one
    final Path crescentPath = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: center, radius: size.width * 0.45)),
      Path()..addOval(Rect.fromCircle(
        center: center.translate(size.width * 0.18, 0), 
        radius: size.width * 0.38
      )),
    );
    canvas.drawPath(crescentPath, paint);

    // ── Star ─────────────────────────────────────────
    final starPath = Path();
    final starCenter = center.translate(size.width * 0.22, 0);
    const int points = 5;
    final double outerRadius = size.width * 0.16;
    final double innerRadius = size.width * 0.07;

    for (int i = 0; i < points; i++) {
      double angle = (i * 72 - 90) * math.pi / 180;
      starPath.lineTo(
        starCenter.dx + outerRadius * math.cos(angle),
        starCenter.dy + outerRadius * math.sin(angle),
      );
      angle += math.pi / points;
      starPath.lineTo(
        starCenter.dx + innerRadius * math.cos(angle),
        starCenter.dy + innerRadius * math.sin(angle),
      );
    }
    starPath.close();
    canvas.drawPath(starPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      double angle = (i * 60 - 90) * (math.pi / 180);
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    for (int i = 0; i < 6; i++) {
      double angle = (i * 60 - 90) * (math.pi / 180);
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Main gold border
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.goldGlow, AppColors.gold, AppColors.goldLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawPath(path, paint);

    // Subtle inner glow line
    final innerPaint = Paint()
      ..color = AppColors.gold.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawPath(
      path.shift(const Offset(0, 0)), 
      innerPaint
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
