import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String id;
  final String name;
  final String? photoUrl;
  final String? college;
  final int totalPoints;
  final int rank;
  final List<String> badges;
  final int coins;

  LeaderboardEntry({
    required this.id,
    required this.name,
    this.photoUrl,
    this.college,
    required this.totalPoints,
    required this.rank,
    this.badges = const [],
    this.coins = 0,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, String id, int rank) {
    return LeaderboardEntry(
      id: id,
      name: map['name'] ?? 'Unknown',
      photoUrl: map['photoUrl'],
      college: map['college'],
      totalPoints: map['totalPoints'] ?? 0,
      rank: rank,
      badges: List<String>.from(map['badges'] ?? []),
      coins: map['coins'] ?? 0,
    );
  }
}

