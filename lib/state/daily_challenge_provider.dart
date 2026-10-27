import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/daily_challenge.dart';
import '../data/repositories/daily_challenge_repository.dart';

class DailyChallengeState {
  const DailyChallengeState({
    this.isLoading = true,
    this.isCompleted = false,
    this.todayChallenge,
    this.dailyStreak = 0,
    this.totalCompleted = 0,
    this.error,
  });

  final bool isLoading;
  final bool isCompleted;
  final DailyChallenge? todayChallenge;
  final int dailyStreak;
  final int totalCompleted;
  final String? error;
}

class DailyChallengeNotifier extends Notifier<DailyChallengeState> {
  @override
  DailyChallengeState build() {
    Future.microtask(refresh);
    return const DailyChallengeState();
  }

  Future<void> refresh() async {
    state = const DailyChallengeState();
    try {
      final overview = await DailyChallengeRepository.instance.getOverview();
      state = DailyChallengeState(
        isLoading: false,
        isCompleted: overview.challenge.isCompleted,
        todayChallenge: overview.challenge,
        dailyStreak: overview.dailyStreak,
        totalCompleted: overview.totalCompleted,
      );
    } catch (_) {
      state = const DailyChallengeState(
        isLoading: false,
        error: 'Failed to load daily challenge',
      );
    }
  }
}

final dailyChallengeProvider =
    NotifierProvider<DailyChallengeNotifier, DailyChallengeState>(
      DailyChallengeNotifier.new,
    );
