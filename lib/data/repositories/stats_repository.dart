import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/auth_provider.dart';
import '../../state/quiz_state.dart';

class StatsRepository {
  StatsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  Future<void> syncQuizStats({
    required String userId,
    required String stageId,
    required QuizState stats,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final batch = _firestore.batch();

    // 1. Update overall user stats (increment totals)
    batch.set(userRef, {
      'totalScore': FieldValue.increment(stats.score),
      'totalCoins': FieldValue.increment(stats.coinsEarned),
      'lastPlayed': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Save stage-specific attempt
    final historyRef = userRef.collection('quiz_history').doc();
    batch.set(historyRef, {
      'stageId': stageId,
      'score': stats.score,
      'totalQuestions': stats.totalQuestions,
      'accuracy': stats.scorePercent,
      'streak': stats.streak,
      'bestStreak': stats.bestStreak,
      'coinsEarned': stats.coinsEarned,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository(ref.watch(firestoreProvider));
});
