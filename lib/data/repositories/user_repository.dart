import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? avatarEmoji,
    String? country,
  }) async {
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (avatarEmoji != null) updates['avatarEmoji'] = avatarEmoji;
    if (country != null) updates['country'] = country;

    if (updates.isEmpty) return;

    await _firestore.collection('users').doc(uid).update(updates);
  }

  Future<void> updateStats({
    required String uid,
    required int correctAnswers,
    required int totalAnswers,
    required int streak,
    required int stagesCompleted,
  }) async {
    final userRef = _firestore.collection('users').doc(uid);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);

      if (!snapshot.exists) {
        transaction.set(userRef, {
          'totalCorrect': correctAnswers,
          'totalQuestions': totalAnswers,
          'bestStreak': streak,
          'stagesCompleted': stagesCompleted,
          'lastPlayed': FieldValue.serverTimestamp(),
        });
      } else {
        final data = snapshot.data()!;
        final currentBestStreak = data['bestStreak'] as int? ?? 0;
        
        transaction.update(userRef, {
          'totalCorrect': FieldValue.increment(correctAnswers),
          'totalQuestions': FieldValue.increment(totalAnswers),
          'bestStreak': streak > currentBestStreak ? streak : currentBestStreak,
          'stagesCompleted': FieldValue.increment(stagesCompleted),
          'lastPlayed': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
