import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';
import '../../../data/models/quiz_model.dart';


class StageCard extends StatelessWidget {
  const StageCard({
    super.key,
    required this.stage,
    required this.difficulty,
    required this.onTap,
  });

  final Stage stage;
  final Difficulty difficulty;
  final VoidCallback? onTap;

  Color get _color {
    switch (difficulty) {
      case Difficulty.easy:   return AppColors.easy;
      case Difficulty.medium: return AppColors.medium;
      case Difficulty.hard:   return AppColors.hard;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (stage.status) {
      case StageStatus.completed:
        return _CompletedCard(stage: stage, color: _color, onTap: onTap);
      case StageStatus.unlocked:
      case StageStatus.current:
        return _CurrentCard(stage: stage, color: _color, onTap: onTap);
      case StageStatus.locked:
        return _LockedCard(stage: stage);
    }
  }
}

// ── Completed card ─────────────────────────────
class _CompletedCard extends StatelessWidget {
  const _CompletedCard({
    required this.stage,
    required this.color,
    required this.onTap,
  });

  final Stage stage;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stage number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${stage.stageNumber}',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.check_circle_rounded,
                    color: color,
                    size: 18,
                  ),
                ],
              ),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return Icon(
                    i < stage.starsEarned
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: i < stage.starsEarned
                        ? AppColors.gold
                        : AppColors.darkBorder,
                    size: 18,
                  );
                }),
              ),

              // Score
              Text(
                '${stage.bestScore}%',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Current card (unlocked, playable) ──────────
class _CurrentCard extends StatelessWidget {
  const _CurrentCard({
    required this.stage,
    required this.color,
    required this.onTap,
  });

  final Stage stage;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              AppColors.darkCard,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stage number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${stage.stageNumber}',
                        style: TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  // Pulsing play icon
                  _PulsingPlay(color: color),
                ],
              ),

              // Current badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border:
                  Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  'PLAY',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              // Empty stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                      (_) => Icon(
                    Icons.star_outline_rounded,
                    color: AppColors.darkBorder,
                    size: 18,
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

// ── Locked card ────────────────────────────────
class _LockedCard extends StatelessWidget {
  const _LockedCard({required this.stage});
  final Stage stage;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkBorder,
          width: 1,
          // dashed effect via custom painter below
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Stage number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.darkBorder.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${stage.stageNumber}',
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
                const Icon(
                  Icons.lock_rounded,
                  color: AppColors.textMuted,
                  size: 16,
                ),
              ],
            ),

            const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.darkBorder,
              size: 28,
            ),

            // Locked stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (_) => Icon(
                  Icons.star_outline_rounded,
                  color: AppColors.darkBorder,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pulsing play button animation ──────────────
class _PulsingPlay extends StatefulWidget {
  const _PulsingPlay({required this.color});
  final Color color;

  @override
  State<_PulsingPlay> createState() => _PulsingPlayState();
}

class _PulsingPlayState extends State<_PulsingPlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(
        Icons.play_circle_filled_rounded,
        color: widget.color,
        size: 22,
      ),
    );
  }
}