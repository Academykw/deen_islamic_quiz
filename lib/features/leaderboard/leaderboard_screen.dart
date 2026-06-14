import 'package:deen_iq/features/leaderboard/podium_widget.dart';
import 'package:deen_iq/features/leaderboard/rank_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constant/app_colors.dart';
import '../../core/widgets/coin_badge.dart';
import '../../core/widgets/geo_background.dart';
import '../../state/auth_provider.dart';
import '../../state/leaderboard_provider.dart';
import 'leaderboard_row.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger initial load
    Future.microtask(() {
      ref.read(leaderboardProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardProvider);
    final currentUser = ref.watch(currentUserProvider);
    final currentUid = currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Stack(
        children: [
          const GeoBackground(),
          SafeArea(
            child: Column(
              children: [
                // ── App bar ───────────────────────
                const _LeaderboardAppBar(),

                // ── Filter chips ──────────────────
                _FilterChips(
                  currentFilter: state.filter,
                  onFilterChanged: (f) =>
                      ref.read(leaderboardProvider.notifier).changeFilter(f),
                ),

                const SizedBox(height: 8),

                // ── Content ───────────────────────
                Expanded(
                  child: state.isLoading
                      ? const _LoadingView()
                      : state.error != null
                          ? _ErrorView(
                              message: state.error!,
                              onRetry: () =>
                                  ref.read(leaderboardProvider.notifier).refresh(),
                            )
                          : state.entries.isEmpty
                              ? const _EmptyView()
                              : RefreshIndicator(
                                  color: AppColors.gold,
                                  backgroundColor: AppColors.darkCard,
                                  onRefresh: () async {
                                    ref
                                        .read(leaderboardProvider.notifier)
                                        .refresh();
                                  },
                                  child: CustomScrollView(
                                    slivers: [
                                      SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 8, 20, 0),
                                        sliver: SliverList(
                                          delegate: SliverChildListDelegate([
                                            // Podium
                                            PodiumWidget(
                                              topThree: state.topThree,
                                              currentUid: currentUid,
                                            ),

                                            const SizedBox(height: 20),

                                            // Your rank card
                                            if (state.currentUserRank > 0) ...[
                                              YourRankCard(
                                                rank: state.currentUserRank,
                                                entry: state.currentUserEntry,
                                              ),
                                              const SizedBox(height: 16),
                                            ],

                                            // Section label
                                            const _SectionLabel(
                                                text: 'RANKINGS'),
                                            const SizedBox(height: 10),
                                          ]),
                                        ),
                                      ),

                                      // Rest of list
                                      SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 0, 20, 80),
                                        sliver: SliverList.builder(
                                          itemCount: state.restOfList.length,
                                          itemBuilder: (_, i) {
                                            final entry = state.restOfList[i];
                                            return LeaderboardRow(
                                              entry: entry,
                                              isCurrentUser:
                                                  entry.uid == currentUid,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── App bar ────────────────────────────────────
class _LeaderboardAppBar extends StatelessWidget {
  const _LeaderboardAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leaderboard',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'لوحة المتصدرين',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          const Spacer(),
          const CoinBadge(size: CoinBadgeSize.small),
        ],
      ),
    );
  }
}

// ── Filter chips ───────────────────────────────
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.currentFilter,
    required this.onFilterChanged,
  });

  final LeaderboardFilter currentFilter;
  final ValueChanged<LeaderboardFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _FilterChip(
            label: '🌍 Global',
            isActive: currentFilter == LeaderboardFilter.global,
            onTap: () => onFilterChanged(LeaderboardFilter.global),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '📅 This Week',
            isActive: currentFilter == LeaderboardFilter.thisWeek,
            onTap: () => onFilterChanged(LeaderboardFilter.thisWeek),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '🗺 My Country',
            isActive: currentFilter == LeaderboardFilter.country,
            onTap: () => onFilterChanged(LeaderboardFilter.country),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.gold.withValues(alpha: 0.15)
              : AppColors.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? AppColors.gold.withValues(alpha: 0.5)
                : AppColors.darkBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? AppColors.gold : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Section label ──────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }
}

// ── Loading view ───────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text(
            'Loading rankings...',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error view ─────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty view ─────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🏆', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text(
            'No rankings yet',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Complete stages to appear here!',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
