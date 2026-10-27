import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/daily_challenge.dart';

class DailyChallengeOverview {
  const DailyChallengeOverview({
    required this.challenge,
    required this.dailyStreak,
    required this.totalCompleted,
  });

  final DailyChallenge challenge;
  final int dailyStreak;
  final int totalCompleted;
}

/// Server-authoritative daily gameplay. The device never receives an answer
/// key before submitting and never writes rewards, completion, or streaks.
class DailyChallengeRepository {
  DailyChallengeRepository._();
  static final DailyChallengeRepository instance = DailyChallengeRepository._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instanceFor(region: 'africa-south1');

  Future<Map<String, dynamic>> startSession() async {
    final result = await _functions.httpsCallable('startDailyChallenge').call();
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<Map<String, dynamic>> submitAnswer({
    required String sessionId,
    required String questionId,
    required int selectedIndex,
    required String requestId,
  }) async {
    final callable = _functions.httpsCallable(
      'submitDailyChallengeAnswer',
      options: HttpsCallableOptions(limitedUseAppCheckToken: true),
    );
    final result = await callable.call({
      'sessionId': sessionId,
      'questionId': questionId,
      'selectedIndex': selectedIndex,
      'requestId': requestId,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<DailyChallengeOverview> getOverview() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in to load the daily challenge.');
    final date = DailyChallenge.todayKey();
    final userRef = _db.collection('users').doc(user.uid);
    final results = await Future.wait([
      userRef.get(),
      userRef.collection('daily_progress').doc(date).get(),
    ]);
    final userData = results[0].data() ?? const <String, dynamic>{};
    final progressData = results[1].data();
    final challenge = progressData == null
        ? DailyChallenge(date: date, questionIds: const [])
        : DailyChallenge(
            date: date,
            questionIds: const [],
            isCompleted: true,
            score: progressData['score'] as int? ?? 0,
            coinsEarned: progressData['coinsEarned'] as int? ?? 0,
            completedAt: (progressData['completedAt'] as Timestamp?)?.toDate(),
          );
    return DailyChallengeOverview(
      challenge: challenge,
      dailyStreak: userData['dailyStreak'] as int? ?? 0,
      totalCompleted: userData['dailyCompleted'] as int? ?? 0,
    );
  }
}
