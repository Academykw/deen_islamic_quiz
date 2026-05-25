import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/gold_button.dart';

class QuickPlayCard extends StatelessWidget {
  const QuickPlayCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1F3D2A),
            AppColors.darkCard,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Row(
          children: [
            // ── Left: text ───────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'QUICK PLAY',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Test Your\nIslamic Knowledge',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Choose difficulty, complete stages\nand earn real coins',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GoldButton(
                    label: 'Play Now',
                    onTap: onTap,
                    height: 44,
                    width: 140,
                    icon: Icons.play_circle_rounded,
                  ),
                ],
              ),
            ),

            // ── Right: decorative orb ────────────
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.emeraldMid.withOpacity(0.6),
                    AppColors.emerald.withOpacity(0.2),
                    AppColors.transparent,
                  ],
                ),
                border: Border.all(
                  color: AppColors.gold.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text(
                  '☪',
                  style: TextStyle(fontSize: 42, color: AppColors.gold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}