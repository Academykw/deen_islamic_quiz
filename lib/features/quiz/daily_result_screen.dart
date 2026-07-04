import 'package:deen_iq/features/quiz/widget/coin_earn_animation.dart';
import 'package:deen_iq/features/quiz/widget/star_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constant/app_colors.dart';
import '../../core/widgets/geo_background.dart';
import '../../core/widgets/gold_button.dart';
import '../../app/router.dart';


class DailyResultExtra {
  const DailyResultExtra({
    required this.score,
    required this.total,
    required this.coinsEarned,
    required this.bestStreak,
  });

  final int score;
  final int total;
  final int coinsEarned;
  final int bestStreak;
}

class DailyResultScreen extends ConsumerStatefulWidget {
  const DailyResultScreen({
    super.key,
    required this.extra,
  });

  final DailyResultExtra extra;

  @override
  ConsumerState<DailyResultScreen> createState() =>
      _DailyResultScreenState();
}

class _DailyResultScreenState
    extends ConsumerState<DailyResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _scoreCtrl;
  late Animation<int> _scoreAnim;

  int get _scorePercent =>
      ((widget.extra.score / widget.extra.total) * 100)
          .round();

  int get _stars {
    if (_scorePercent >= 90) return 3;
    if (_scorePercent >= 70) return 2;
    if (_scorePercent >= 50) return 1;
    return 0;
  }

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(
        parent: _fadeCtrl, curve: Curves.easeIn);

    _scoreCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scoreAnim = IntTween(
      begin: 0,
      end: _scorePercent,
    ).animate(CurvedAnimation(
        parent: _scoreCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 300),
            () {
          if (mounted) _scoreCtrl.forward();
        });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }

  String get _title {
    if (_scorePercent >= 90) return 'ما شاء الله!';
    if (_scorePercent >= 70) return 'أحسنت!';
    if (_scorePercent >= 50) return 'جيد!';
    return 'حاول غداً';
  }

  String get _titleEn {
    if (_scorePercent >= 90) return 'Masha\'Allah!';
    if (_scorePercent >= 70) return 'Excellent!';
    if (_scorePercent >= 50) return 'Good Job!';
    return 'Try Again Tomorrow!';
  }

  Color get _scoreColor {
    if (_scorePercent >= 70) return AppColors.emeraldLight;
    if (_scorePercent >= 50) return AppColors.gold;
    return AppColors.wrong;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          const GeoBackground(),
          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    20, 20, 20, 40),
                child: Column(
                  children: [

                    // ── Daily badge ───────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.emerald
                            .withOpacity(0.15),
                        borderRadius:
                        BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.emeraldLight
                                .withOpacity(0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons
                                .local_fire_department_rounded,
                            color: AppColors.emeraldLight,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Daily Challenge Complete',
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.emeraldLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Score orb ─────────────────
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _scoreColor.withOpacity(0.3),
                            _scoreColor.withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                            color: _scoreColor, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color:
                            _scoreColor.withOpacity(0.3),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _scoreAnim,
                              builder: (_, __) => Text(
                                '${_scoreAnim.value}%',
                                style: TextStyle(
                                  fontFamily: 'Tajawal',
                                  fontSize: 28,
                                  fontWeight:
                                  FontWeight.w800,
                                  color: _scoreColor,
                                ),
                              ),
                            ),
                            Text(
                              '${widget.extra.score}/${widget.extra.total}',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 12,
                                color: _scoreColor
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Arabic title
                    Text(
                      _title,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: AppColors.goldLight,
                      ),
                      textDirection: TextDirection.rtl,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _titleEn,
                      style: const TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stars
                    StarDisplay(stars: _stars),

                    const SizedBox(height: 20),

                    // Coins
                    CoinEarnAnimation(
                        coinsEarned: widget.extra.coinsEarned),

                    const SizedBox(height: 20),

                    // Stats card
                    _DailyStatsCard(extra: widget.extra),

                    const SizedBox(height: 24),

                    // ── Tomorrow notice ───────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius:
                        BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.darkBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.event_rounded,
                              color: AppColors.gold,
                              size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Come back tomorrow for a new daily challenge and more coins!',
                              style: TextStyle(
                                fontFamily: 'Tajawal',
                                fontSize: 13,
                                color:
                                AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Back home
                    GoldButton(
                      label: 'Back to Home',
                      onTap: () =>
                          context.goNamed(Routes.home),
                      icon: Icons.home_rounded,
                    ),

                    const SizedBox(height: 10),

                    GoldButton(
                      label: 'View Leaderboard',
                      onTap: () =>
                          context.goNamed(Routes.leaderboard),
                      variant: GoldButtonVariant.outlined,
                      icon: Icons.leaderboard_rounded,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyStatsCard extends StatelessWidget {
  const _DailyStatsCard({required this.extra});
  final DailyResultExtra extra;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    color: AppColors.gold, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Daily Stats',
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
              height: 1, color: AppColors.darkBorder),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _DailyStat(
                  icon: Icons.check_circle_rounded,
                  label: 'Correct',
                  value: '${extra.score}',
                  color: AppColors.correct,
                ),
                _Divider(),
                _DailyStat(
                  icon: Icons.cancel_rounded,
                  label: 'Wrong',
                  value:
                  '${extra.total - extra.score}',
                  color: AppColors.wrong,
                ),
                _Divider(),
                _DailyStat(
                  icon: Icons
                      .local_fire_department_rounded,
                  label: 'Streak',
                  value: '${extra.bestStreak}',
                  color: AppColors.gold,
                ),
                _Divider(),
                _DailyStat(
                  icon: Icons.monetization_on_rounded,
                  label: 'Coins',
                  value: '+${extra.coinsEarned}',
                  color: AppColors.coin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyStat extends StatelessWidget {
  const _DailyStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 10,
                  color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 1, height: 40, color: AppColors.darkBorder);
  }
}