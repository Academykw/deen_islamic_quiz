import 'package:flutter/material.dart';

import '../constant/app_colors.dart';


class CoinBadge extends StatelessWidget {
  const CoinBadge({
    super.key,
    required this.amount,
    this.size = CoinBadgeSize.medium,
    this.animate = false,
  });

  final int amount;
  final CoinBadgeSize size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final double iconSize = size == CoinBadgeSize.small ? 14 : 18;
    final double fontSize = size == CoinBadgeSize.small ? 13 : 15;
    final EdgeInsets padding = size == CoinBadgeSize.small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.coin.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.coin.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on_rounded,
              color: AppColors.coin, size: iconSize),
          const SizedBox(width: 5),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Text(
              _formatCoins(amount),
              key: ValueKey(amount),
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.coin,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCoins(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

enum CoinBadgeSize { small, medium }