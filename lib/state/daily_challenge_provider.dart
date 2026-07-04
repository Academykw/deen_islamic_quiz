import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/daily_challenge.dart';
import '../data/models/quiz_model.dart';
import '../data/repositories/daily_challenge_repository.dart';

class DailyChallengeState {
  const DailyChallengeState({
    this.isLoading = true,
    this.isCompleted = false,
    this.questions = const [],
    this.todayChallenge,
    this.dailyStreak = 0,
    this.totalCompleted = 0,
    this.error,
  });

  final bool isLoading;
  final bool isCompleted;
  final List<Question> questions;
  final DailyChallenge? todayChallenge;
  final int dailyStreak;
  final int totalCompleted;
  final String? error;

  DailyChallengeState copyWith({
    bool? isLoading,
    bool? isCompleted,
    List<Question>? questions,
    DailyChallenge? todayChallenge,
    int? dailyStreak,
    int? totalCompleted,
    String? error,
  }) {
    return DailyChallengeState(
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      questions: questions ?? this.questions,
      todayChallenge: todayChallenge ?? this.todayChallenge,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      error: error ?? this.error,
    );
  }
}

class DailyChallengeNotifier extends Notifier<DailyChallengeState> {
  @override
  DailyChallengeState build() {
    _init();
    return const DailyChallengeState();
  }

  DailyChallengeRepository get _repo => DailyChallengeRepository.instance;

  Future<void> _init() async {
    try {
      final isCompleted = await _repo.isTodayCompleted();
      final dailyStreak = await _repo.getDailyStreak();
      final totalCompleted = await _repo.getTotalCompleted();
      final challenge = await _repo.getTodayChallenge();

      List<Question> questions = [];
      if (!isCompleted) {
        questions = await _repo.getChallengeQuestions();
      }

      state = state.copyWith(
        isLoading: false,
        isCompleted: isCompleted,
        questions: questions,
        todayChallenge: challenge,
        dailyStreak: dailyStreak,
        totalCompleted: totalCompleted,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load daily challenge',
      );
    }
  }

  Future<void> markCompleted({
    required int score,
    required int coinsEarned,
  }) async {
    final today = DailyChallenge.todayKey();

    await _repo.completeChallenge(
      date: today,
      score: score,
      coinsEarned: coinsEarned,
    );

    final newStreak = await _repo.getDailyStreak();
    final newTotal = await _repo.getTotalCompleted();

    state = state.copyWith(
      isCompleted: true,
      dailyStreak: newStreak,
      totalCompleted: newTotal,
    );
  }

  Future<void> refresh() async {
    state = const DailyChallengeState();
    await _init();
  }

  List<Question> get questions => state.questions;
}

final dailyChallengeProvider =
    NotifierProvider<DailyChallengeNotifier, DailyChallengeState>(
  DailyChallengeNotifier.new,
);
