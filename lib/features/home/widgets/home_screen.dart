import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../data/models/quiz_model.dart';
import '../../../state/auth_provider.dart';
import '../../../state/quiz_provider.dart';
import 'daily_challenge_card.dart';
import 'live_quiz_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final easyStages = ref.watch(easyStagesProvider);
    final mediumStages = ref.watch(mediumStagesProvider);
    final hardStages = ref.watch(hardStagesProvider);
    final profile = ref
        .watch(userProfileProvider)
        .when(
          data: (value) => value,
          loading: () => null,
          error: (_, _) => null,
        );
    final stages = [...easyStages, ...mediumStages, ...hardStages];
    final completed = stages.where((stage) => stage.isCompleted).length;
    final totalStars = stages.fold<int>(
      0,
      (total, stage) => total + stage.starsEarned,
    );

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.pageGlow),
        child: Stack(
          children: [
            const _AmbientPattern(),
            SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _HomeHeader(
                          displayName: profile?.displayName,
                          onProfileTap: () => context.pushNamed(Routes.profile),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
                        sliver: SliverList.list(
                          children: [
                            _WelcomeBlock(displayName: profile?.displayName),
                            const SizedBox(height: 20),
                            _JourneyHero(
                              completed: completed,
                              total: stages.isEmpty ? 150 : stages.length,
                              stars: totalStars,
                              onTap: () => context.pushNamed(Routes.difficulty),
                            ),
                            const SizedBox(height: 28),
                            const _SectionHeader(
                              eyebrow: 'PLAY TODAY',
                              title: 'Fresh ways to test your knowledge',
                            ),
                            const SizedBox(height: 14),
                            const LiveQuizCard(),
                            const SizedBox(height: 12),
                            DailyChallengeCard(
                              onTap: () =>
                                  context.pushNamed(Routes.dailyChallenge),
                            ),
                            const SizedBox(height: 28),
                            const _SectionHeader(
                              eyebrow: 'YOUR JOURNEY',
                              title: 'Progress across every level',
                            ),
                            const SizedBox(height: 14),
                            _TrackProgress(
                              easyStages: easyStages,
                              mediumStages: mediumStages,
                              hardStages: hardStages,
                            ),
                            const SizedBox(height: 28),
                            const _SectionHeader(
                              eyebrow: 'COMMUNITY & REWARDS',
                              title: 'See your standing and earned Acoins',
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: _FeatureCard(
                                    icon: Icons.public_rounded,
                                    title: 'Leaderboards',
                                    subtitle: 'Country & global',
                                    color: AppColors.lifelineBlue,
                                    onTap: () =>
                                        context.pushNamed(Routes.leaderboard),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _FeatureCard(
                                    icon: Icons.account_balance_wallet_rounded,
                                    title: 'Acoin wallet',
                                    subtitle: 'Balance & history',
                                    color: AppColors.gold,
                                    onTap: () =>
                                        context.pushNamed(Routes.wallet),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const _TrustStrip(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DeenBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              context.goNamed(Routes.home);
              break;
            case 1:
              context.pushNamed(Routes.leaderboard);
              break;
            case 2:
              context.pushNamed(Routes.profile);
              break;
            case 3:
              context.pushNamed(Routes.wallet);
              break;
          }
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.displayName, required this.onProfileTap});

  final String? displayName;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
            ),
            padding: const EdgeInsets.all(7),
            child: Image.asset('assets/images/app_icon.png'),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEEN IQ',
                  style: TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Learn  •  Play  •  Grow',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const CoinBadge(),
          const SizedBox(width: 8),
          Semantics(
            label: 'Open profile',
            button: true,
            child: InkWell(
              onTap: onProfileTap,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.darkPanel,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                alignment: Alignment.center,
                child: Text(
                  _initial(displayName),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _initial(String? name) {
    final cleanName = name?.trim() ?? '';
    return cleanName.isEmpty ? 'D' : cleanName[0].toUpperCase();
  }
}

class _WelcomeBlock extends StatelessWidget {
  const _WelcomeBlock({this.displayName});

  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final firstName = (displayName?.trim().isNotEmpty ?? false)
        ? displayName!.trim().split(RegExp(r'\s+')).first
        : 'learner';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'السلام عليكم',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Amiri',
            color: AppColors.goldLight,
            fontSize: 30,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Welcome back, $firstName',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'A little knowledge each day builds a lasting journey.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

class _JourneyHero extends StatelessWidget {
  const _JourneyHero({
    required this.completed,
    required this.total,
    required this.stars,
    required this.onTap,
  });

  final int completed;
  final int total;
  final int stars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.emeraldLight.withValues(alpha: 0.28),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cream.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.goldLight,
                  size: 26,
                ),
              ),
              const Spacer(),
              _HeroStat(icon: Icons.star_rounded, value: '$stars stars'),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Continue your journey',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 23,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Choose Easy, Medium, or Hard. Each stage gives you 10 questions and useful lifelines.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: progress,
                    backgroundColor: AppColors.dark.withValues(alpha: 0.45),
                    valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$completed/$total',
                style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(completed == 0 ? 'Start learning' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.dark.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.gold),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TrackProgress extends StatelessWidget {
  const _TrackProgress({
    required this.easyStages,
    required this.mediumStages,
    required this.hardStages,
  });

  final List<Stage> easyStages;
  final List<Stage> mediumStages;
  final List<Stage> hardStages;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          _ProgressRow(
            label: 'Easy',
            description: 'Build strong foundations',
            color: AppColors.easy,
            stages: easyStages,
            onTap: () => _openStages(context, Difficulty.easy),
          ),
          const Divider(indent: 18, endIndent: 18),
          _ProgressRow(
            label: 'Medium',
            description: 'Deepen your understanding',
            color: AppColors.medium,
            stages: mediumStages,
            onTap: () => _openStages(context, Difficulty.medium),
          ),
          const Divider(indent: 18, endIndent: 18),
          _ProgressRow(
            label: 'Hard',
            description: 'Challenge what you know',
            color: AppColors.hard,
            stages: hardStages,
            onTap: () => _openStages(context, Difficulty.hard),
          ),
        ],
      ),
    );
  }

  static void _openStages(BuildContext context, Difficulty difficulty) {
    context.pushNamed(
      Routes.stages,
      pathParameters: {'difficulty': difficulty.name},
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.description,
    required this.color,
    required this.stages,
    required this.onTap,
  });

  final String label;
  final String description;
  final Color color;
  final List<Stage> stages;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final completed = stages.where((stage) => stage.isCompleted).length;
    final total = stages.isEmpty ? 50 : stages.length;
    final progress = (completed / total).clamp(0.0, 1.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.layers_rounded, color: color, size: 21),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        '$completed/$total',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: progress,
                      backgroundColor: AppColors.darkBorder,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.emeraldLight.withValues(alpha: 0.18),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: AppColors.emeraldLight,
            size: 19,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Scores, progress, and Acoin rewards are verified securely.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbientPattern extends StatelessWidget {
  const _AmbientPattern();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -90,
      right: -80,
      child: IgnorePointer(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.06),
              width: 34,
            ),
          ),
        ),
      ),
    );
  }
}
