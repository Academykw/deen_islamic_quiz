import 'package:flutter/material.dart';

import '../../../core/constant/app_colors.dart';
import '../../../data/models/lifeline.dart';

class LifelineButton extends StatelessWidget {
  const LifelineButton({
    super.key,
    required this.lifeline,
    required this.onTap,
  });

  final Lifeline lifeline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // We allow clicking even if disabled by coins to show feedback/description
    final isUsed = lifeline.isUsed;
    final canAfford = !lifeline.isDisabled;
    final isAvailable = !isUsed;

    return GestureDetector(
      onTap: isAvailable ? () => _confirmUse(context) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isUsed ? 0.35 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 10),
          constraints: const BoxConstraints(minHeight: 65),
          decoration: BoxDecoration(
            color: isAvailable
                ? lifeline.color.withValues(alpha: 0.12)
                : AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAvailable
                  ? lifeline.color.withValues(alpha: 0.4)
                  : AppColors.darkBorder,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Icon(
                isUsed
                    ? Icons.check_rounded
                    : lifeline.icon,
                color: isAvailable
                    ? (canAfford ? lifeline.color : lifeline.color.withValues(alpha: 0.5))
                    : AppColors.textMuted,
                size: 20,
              ),
              const SizedBox(height: 3),
              // Label
              Text(
                lifeline.label,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isAvailable
                      ? (canAfford ? lifeline.color : lifeline.color.withValues(alpha: 0.5))
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              // Coin cost
              if (!isUsed)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: AppColors.coin.withValues(alpha: 
                          canAfford ? 0.8 : 0.4),
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${lifeline.coinCost}',
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 10,
                        color: AppColors.coin.withValues(alpha: 
                            canAfford ? 0.8 : 0.4),
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'Used',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmUse(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: lifeline.color.withValues(alpha: 0.4),
              width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: lifeline.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: lifeline.color, width: 1.5),
              ),
              child: Icon(lifeline.icon,
                  color: lifeline.color, size: 28),
            ),

            const SizedBox(height: 14),

            Text(
              lifeline.label,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: lifeline.color,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              lifeline.description,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Cost row
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.coin.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.coin.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: AppColors.coin,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Costs ${lifeline.coinCost} coins',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.coin,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Use button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      lifeline.color.withValues(alpha: 0.8),
                      lifeline.color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Material(
                  color: AppColors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onTap?.call();
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child: Text(
                        'Use Lifeline',
                        style: const TextStyle(
                          fontFamily: 'Tajawal',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Cancel
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
