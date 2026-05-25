import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

class CoinEarnAnimation extends StatefulWidget {
  const CoinEarnAnimation({
    super.key,
    required this.coinsEarned,
  });

  final int coinsEarned;

  @override
  State<CoinEarnAnimation> createState() => _CoinEarnAnimationState();
}

class _CoinEarnAnimationState extends State<CoinEarnAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<int> _countAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _countAnim = IntTween(begin: 0, end: widget.coinsEarned).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );

    // Delay slightly so screen has settled
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 28, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.coin.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.coin.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.coin.withOpacity(0.15),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Coins Earned',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: AppColors.coin,
                  size: 32,
                ),
                const SizedBox(width: 10),
                AnimatedBuilder(
                  animation: _countAnim,
                  builder: (_, __) => Text(
                    '+${_countAnim.value}',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: AppColors.coin,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}