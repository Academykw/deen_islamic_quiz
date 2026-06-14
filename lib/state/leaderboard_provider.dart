import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/leaderboard_entry.dart';
import '../data/repositories/leaderboard_repository.dart';
import '../data/repositories/user_repository.dart';
import 'auth_provider.dart';

enum LeaderboardFilter { global, thisWeek, country }

class LeaderboardState {
  const LeaderboardState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
    this.filter = LeaderboardFilter.global,
    this.currentUserRank = 0,
    this.currentUserEntry,
  });

  final List<LeaderboardEntry> entries;
  final bool isLoading;
  final String? error;
  final LeaderboardFilter filter;
  final int currentUserRank;
  final LeaderboardEntry? currentUserEntry;

  List<LeaderboardEntry> get topThree =>
      entries.take(3).toList();

  List<LeaderboardEntry> get restOfList =>
      entries.skip(3).toList();

  LeaderboardState copyWith({
    List<LeaderboardEntry>? entries,
    bool? isLoading,
    String? error,
    bool clearError = false,
    LeaderboardFilter? filter,
    int? currentUserRank,
    LeaderboardEntry? currentUserEntry,
  }) {
    return LeaderboardState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      filter: filter ?? this.filter,
      currentUserRank: currentUserRank ?? this.currentUserRank,
      currentUserEntry: currentUserEntry ?? this.currentUserEntry,
    );
  }
}

class LeaderboardNotifier extends Notifier<LeaderboardState> {
  @override
  LeaderboardState build() {
    // We don't want to call loadLeaderboard() here because it's async
    // and this is a synchronous build method.
    // Instead we can use Future.microtask or just trigger it from the UI.
    // But for simplicity, we can just initialize and let the screen call refresh.
    return const LeaderboardState();
  }

  final _repo = LeaderboardRepository.instance;

  Future<void> loadLeaderboard({
    LeaderboardFilter? filter,
  }) async {
    final activeFilter = filter ?? state.filter;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      filter: activeFilter,
    );

    try {
      List<LeaderboardEntry> entries;

      switch (activeFilter) {
        case LeaderboardFilter.global:
          entries = await _repo.getGlobalLeaderboard();
          break;
        case LeaderboardFilter.thisWeek:
          entries = await _repo.getWeeklyLeaderboard();
          break;
        case LeaderboardFilter.country:
          final user = ref.read(currentUserProvider);
          if (user == null) {
            entries = await _repo.getGlobalLeaderboard();
          } else {
            final userData = await UserRepository.instance.getUserData(user.uid);
            final country = userData?['country'] as String? ?? '';
            if (country.isEmpty) {
              entries = await _repo.getGlobalLeaderboard();
            } else {
              entries = await _repo.getCountryLeaderboard(country);
            }
          }
          break;
      }

      // Get current user rank
      final uid = ref.read(currentUserProvider)?.uid;
      int userRank = 0;
      LeaderboardEntry? userEntry;

      if (uid != null) {
        userRank = await _repo.getUserRank(uid);
        // Find user in list
        try {
          userEntry = entries.firstWhere(
            (e) => e.uid == uid,
          );
        } catch (_) {
          // User not in top list
          userEntry = null;
        }
      }

      state = state.copyWith(
        entries: entries,
        isLoading: false,
        currentUserRank: userRank,
        currentUserEntry: userEntry,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load leaderboard. Pull to refresh.',
      );
    }
  }

  void changeFilter(LeaderboardFilter filter) {
    if (filter == state.filter) return;
    loadLeaderboard(filter: filter);
  }

  void refresh() => loadLeaderboard();
}

final leaderboardProvider =
    NotifierProvider<LeaderboardNotifier, LeaderboardState>(LeaderboardNotifier.new);
