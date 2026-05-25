import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class StreakIndicator extends StatelessWidget {
  const StreakIndicator({
    super.key,
    required this.streak,
  });

  final int streak;

  Color get _color {
    if (streak >= 5) return AppColors.hard;
    if (streak >= 3) return AppColors.gold;
    return AppColors.emeraldLight;
  }

  String get _label {
    if (streak >= 5) return '🔥 On Fire!';
    if (streak >= 3) return '⚡ Hot Streak!';
    if (streak >= 1) return '✨ Streak';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    if (streak == 0) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$streak',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}