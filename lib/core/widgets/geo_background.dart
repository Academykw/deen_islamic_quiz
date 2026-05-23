import 'package:flutter/material.dart';

import '../constant/app_colors.dart';


/// Paints the repeating geometric line pattern + radial orbs
/// seen in the original HTML design. Wrap any screen with this.
///
/// Usage:
///   Stack(children: [
///     const GeoBackground(),
///     YourScreenContent(),
///   ])
class GeoBackground extends StatelessWidget {
  const GeoBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _GeoPainter(),
      ),
    );
  }
}

class _GeoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawOrbBottomLeft(canvas, size);
    _drawOrbTopRight(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 60° diagonal lines
    final diag = Paint()
      ..color = AppColors.gold.withOpacity(0.025)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (double x = -size.height; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        diag,
      );
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        diag,
      );
    }
  }

  void _drawOrbBottomLeft(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.emerald.withOpacity(0.15),
          AppColors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(-100, size.height + 100),
        radius: 400,
      ));
    canvas.drawCircle(Offset(-100, size.height + 100), 400, paint);
  }

  void _drawOrbTopRight(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.gold.withOpacity(0.08),
          AppColors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width + 50, size.height * 0.3),
        radius: 300,
      ));
    canvas.drawCircle(Offset(size.width + 50, size.height * 0.3), 300, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}