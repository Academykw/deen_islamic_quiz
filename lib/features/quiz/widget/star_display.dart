import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class StarDisplay extends StatefulWidget {
  const StarDisplay({
    super.key,
    required this.stars,
    this.size = 36,
  });

  final int stars;
  final double size;

  @override
  State<StarDisplay> createState() => _StarDisplayState();
}

class _StarDisplayState extends State<StarDisplay>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scales;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      3,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _scales = _controllers.map((c) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.elasticOut),
      );
    }).toList();

    // Stagger the star animations
    for (int i = 0; i < widget.stars; i++) {
      Future.delayed(Duration(milliseconds: 200 + (i * 200)), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final earned = i < widget.stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: earned
              ? ScaleTransition(
            scale: _scales[i],
            child: Icon(
              Icons.star_rounded,
              color: AppColors.gold,
              size: widget.size,
              shadows: [
                Shadow(
                  color: AppColors.gold.withOpacity(0.5),
                  blurRadius: 12,
                ),
              ],
            ),
          )
              : Icon(
            Icons.star_outline_rounded,
            color: AppColors.darkBorder,
            size: widget.size,
          ),
        );
      }),
    );
  }
}