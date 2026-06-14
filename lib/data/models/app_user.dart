class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.avatarEmoji,
    required this.country,
    required this.totalCorrect,
    required this.totalAttempted,
    required this.bestStreak,
    required this.stagesCompleted,
    required this.isGuest,
  });

  final String uid;
  final String email;
  final String displayName;
  final String avatarEmoji;
  final String country;
  final int totalCorrect;
  final int totalAttempted;
  final int bestStreak;
  final int stagesCompleted;
  final bool isGuest;

  double get accuracy => totalAttempted == 0 
      ? 0 
      : (totalCorrect / totalAttempted) * 100;

  factory AppUser.fromMap(Map<String, dynamic> map, String uid, {bool isGuest = false}) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? (isGuest ? 'Guest User' : 'Anonymous'),
      avatarEmoji: map['avatarEmoji'] ?? '👤',
      country: map['country'] ?? '',
      totalCorrect: map['totalCorrect'] ?? 0,
      totalAttempted: map['totalQuestions'] ?? 0,
      bestStreak: map['bestStreak'] ?? 0,
      stagesCompleted: map['stagesCompleted'] ?? 0,
      isGuest: isGuest,
    );
  }

  AppUser copyWith({
    String? displayName,
    String? avatarEmoji,
    String? country,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      country: country ?? this.country,
      totalCorrect: totalCorrect,
      totalAttempted: totalAttempted,
      bestStreak: bestStreak,
      stagesCompleted: stagesCompleted,
      isGuest: isGuest,
    );
  }
}
