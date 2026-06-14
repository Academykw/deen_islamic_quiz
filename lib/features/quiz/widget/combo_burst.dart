import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constant/app_colors.dart';


class ComboBurst extends StatefulWidget {
  const ComboBurst({
    super.key,
    required this.streak,
    required this.onComplete,
  });

  final int streak;
  final VoidCallback onComplete;

  @override
  State<ComboBurst> createState() => _ComboBurstState();
}

class _ComboBurstState extends State<ComboBurst> {
  @override
  void initState() {
    super.initState();
    // Auto-dismiss after animation completes
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) widget.onComplete();
    });
  }

  String get _title {
    if (widget.streak >= 10) return '🔥 LEGENDARY!';
    if (widget.streak >= 7)  return '⚡ UNSTOPPABLE!';
    if (widget.streak >= 5)  return '🔥 ON FIRE!';
    return '⚡ HOT STREAK!';
  }

  String get _subtitle {
    if (widget.streak >= 10) return '10× streak — 2× coins!';
    if (widget.streak >= 7)  return '7× streak — 2× coins!';
    if (widget.streak >= 5)  return '5× streak — 2× coins!';
    return '3× streak — 1.5× coins!';
  }

  Color get _color {
    if (widget.streak >= 5) return AppColors.hard;
    return AppColors.gold;
  }

  List<Color> get _gradientColors {
    if (widget.streak >= 5) {
      return [
        const Color(0xFF3D0000),
        AppColors.dark,
      ];
    }
    return [
      const Color(0xFF3D2E00),
      AppColors.dark,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withValues(alpha: 0.65),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Burst particles ────────────────
                _BurstParticles(color: _color),

                const SizedBox(height: 16),

                // ── Main card ──────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _gradientColors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: _color.withValues(alpha: 0.5),
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _color.withValues(alpha: 0.4),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Streak number
                      Text(
                        '${widget.streak}×',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          color: _color,
                          height: 1,
                        ),
                      )
                          .animate()
                          .scale(
                        begin: const Offset(0.3, 0.3),
                        end: const Offset(1.0, 1.0),
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      )
                          .fadeIn(duration: 200.ms),

                      const SizedBox(height: 8),

                      // Title
                      Text(
                        _title,
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _color,
                        ),
                      )
                          .animate(delay: 200.ms)
                          .slideY(
                        begin: 0.5,
                        end: 0,
                        duration: 300.ms,
                        curve: Curves.easeOut,
                      )
                          .fadeIn(duration: 300.ms),

                      const SizedBox(height: 6),

                      // Subtitle
                      Text(
                        _subtitle,
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      )
                          .animate(delay: 350.ms)
                          .fadeIn(duration: 300.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Burst particle effect ──────────────────────
class _BurstParticles extends StatefulWidget {
  const _BurstParticles({required this.color});
  final Color color;

  @override
  State<_BurstParticles> createState() =>
      _BurstParticlesState();
}

class _BurstParticlesState extends State<_BurstParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return SizedBox(
          width: 200,
          height: 80,
          child: CustomPaint(
            painter: _ParticlePainter(
              progress: _ctrl.value,
              color: widget.color,
            ),
          ),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);

    // 12 particles burst outward
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 3.14159 * 2;
      final distance = progress * 90;
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final radius =
      (4 * (1 - progress * 0.5)).clamp(1.0, 6.0);

      paint.color = color.withValues(alpha: opacity * 0.8);
      canvas.drawCircle(
        Offset(
          center.dx + distance * (i % 2 == 0 ? 1 : 0.7) *
              (0.5 + 0.5 * progress) *
              _cos(angle),
          center.dy + distance * 0.5 * _sin(angle),
        ),
        radius,
        paint,
      );
    }
  }

  double _cos(double angle) {
    return (angle < 1.5708)
        ? 1 - angle * angle / 2
        : (angle < 3.14159)
        ? -(angle - 3.14159) * (angle - 3.14159) / 2 + 1 - 1
        : -1 + (angle - 3.14159) * (angle - 3.14159) / 2;
  }

  double _sin(double angle) {
    return _cos(angle - 1.5708);
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.progress != progress;
}