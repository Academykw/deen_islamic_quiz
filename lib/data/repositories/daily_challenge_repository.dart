import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../local/question_seed.dart';
import '../models/daily_challenge.dart';
import '../models/quiz_model.dart';


class DailyChallengeRepository {
  DailyChallengeRepository._();
  static final DailyChallengeRepository instance =
  DailyChallengeRepository._();

  final _db = FirebaseFirestore.instance;

  static const _localKey = 'deen_daily_challenge';
  static const _streakKey = 'deen_daily_streak';
  static const _totalCompletedKey = 'deen_daily_total';

  // ── Get today's challenge ─────────────────────
  Future<DailyChallenge> getTodayChallenge() async {
    final today = DailyChallenge.todayKey();

    // Check local cache first
    final local = await _getLocalChallenge();
    if (local != null && local.date == today) {
      return local;
    }

    // Try Firestore
    try {
      final doc = await _db
          .collection('daily_challenges')
          .doc(today)
          .get();

      if (doc.exists) {
        final challenge =
        DailyChallenge.fromMap(doc.data()!);
        await _saveLocalChallenge(challenge);
        return challenge;
      }
    } catch (_) {
      // Firestore unavailable — use local seed
    }

    // Generate from local seed as fallback
    return _generateLocalChallenge(today);
  }

  /// Generate a daily challenge from seed questions
  /// Uses the date as a seed for consistent daily questions
  DailyChallenge _generateLocalChallenge(String date) {
    // Use date hash to pick consistent questions per day
    final seed = date.hashCode.abs();
    final all = List<Question>.from(kSeedQuestions);

    // Shuffle with date-based seed
    for (int i = all.length - 1; i > 0; i--) {
      final j = (seed + i * 7) % (i + 1);
      final temp = all[i];
      all[i] = all[j];
      all[j] = temp;
    }

    // Take 10 questions
    final selected = all.take(10).toList();

    return DailyChallenge(
      date: date,
      questionIds: selected.map((q) => q.id).toList(),
    );
  }

  // ── Mark challenge as completed ───────────────
  Future<void> completeChallenge({
    required String date,
    required int score,
    required int coinsEarned,
  }) async {
    final challenge = DailyChallenge(
      date: date,
      questionIds: [],
      isCompleted: true,
      score: score,
      coinsEarned: coinsEarned,
      completedAt: DateTime.now(),
    );

    // Save locally
    await _saveLocalChallenge(challenge);

    // Update streak
    await _updateStreak();

    // Update total completed count
    final prefs = await SharedPreferences.getInstance();
    final total = prefs.getInt(_totalCompletedKey) ?? 0;
    await prefs.setInt(_totalCompletedKey, total + 1);
  }

  // ── Check if today is completed ───────────────
  Future<bool> isTodayCompleted() async {
    final local = await _getLocalChallenge();
    if (local == null) return false;
    return local.date == DailyChallenge.todayKey() &&
        local.isCompleted;
  }

  // ── Get daily streak ──────────────────────────
  Future<int> getDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  // ── Get total daily challenges completed ──────
  Future<int> getTotalCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalCompletedKey) ?? 0;
  }

  // ── Get questions for today's challenge ───────
  Future<List<Question>> getChallengeQuestions() async {
    final challenge = await getTodayChallenge();
    if (challenge.questionIds.isEmpty) return [];

    final snapshot = await _db
        .collection('questions')
        .where(FieldPath.documentId, whereIn: challenge.questionIds)
        .get();

    return snapshot.docs
        .map((doc) => Question.fromMap(doc.data(), doc.id))
        .toList();
  }

  // ── Local helpers ─────────────────────────────
  Future<DailyChallenge?> _getLocalChallenge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localKey);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return DailyChallenge.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveLocalChallenge(
      DailyChallenge challenge) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _localKey,
      jsonEncode(challenge.toMap()),
    );
  }

  Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DailyChallenge.todayKey();
    final yesterday = _getDateKey(
        DateTime.now().subtract(const Duration(days: 1)));

    final lastCompleted =
        prefs.getString('deen_daily_last') ?? '';
    final currentStreak =
        prefs.getInt(_streakKey) ?? 0;

    if (lastCompleted == yesterday) {
      // Consecutive day — increment streak
      await prefs.setInt(_streakKey, currentStreak + 1);
    } else if (lastCompleted == today) {
      // Already completed today — no change
      return;
    } else {
      // Streak broken — reset to 1
      await prefs.setInt(_streakKey, 1);
    }

    await prefs.setString('deen_daily_last', today);
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}