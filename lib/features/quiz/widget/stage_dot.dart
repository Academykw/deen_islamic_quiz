import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';
import '../../../data/models/quiz_model.dart';


class StageDot extends StatelessWidget {
  const StageDot({
    super.key,
    required this.status,
    required this.color,
    this.size = 8,
  });

  final StageStatus status;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: status == StageStatus.completed
            ? color
            : status == StageStatus.current
            ? color.withOpacity(0.5)
            : AppColors.darkBorder,
        border: status == StageStatus.current
            ? Border.all(color: color, width: 1.5)
            : null,
      ),
    );
  }
}