class LeaderboardEntry {
  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.avatarEmoji,
    required this.coins,
    required this.rank,
    required this.country,
    required this.accuracy,
    required this.bestStreak,
  });

  final String uid;
  final String displayName;
  final String avatarEmoji;
  final int coins;
  final int rank;
  final String country;
  final double accuracy;
  final int bestStreak;

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, int rank) {
    return LeaderboardEntry(
      uid: map['uid'] ?? '',
      displayName: map['displayName'] ?? 'Anonymous',
      avatarEmoji: map['avatarEmoji'] ?? '👤',
      coins: map['totalCoins'] ?? 0,
      rank: rank,
      country: map['country'] ?? '',
      accuracy: (map['accuracy'] ?? 0).toDouble(),
      bestStreak: map['bestStreak'] ?? 0,
    );
  }
}
