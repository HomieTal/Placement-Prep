import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardStats {
  final int totalTestsTaken;
  final double overallAccuracy;
  final double averageScore;
  final int currentStreak;
  final String strongestCategory;
  final String weakestCategory;
  final int totalQuestionsAttempted;
  final int correctAnswers;
  final int totalPoints;
  final int coins;

  DashboardStats({
    this.totalTestsTaken = 0,
    this.overallAccuracy = 0.0,
    this.averageScore = 0.0,
    this.currentStreak = 0,
    this.strongestCategory = 'N/A',
    this.weakestCategory = 'N/A',
    this.totalQuestionsAttempted = 0,
    this.correctAnswers = 0,
    this.totalPoints = 0,
    this.coins = 0,
  });

  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      totalTestsTaken: map['totalTestsTaken'] ?? 0,
      overallAccuracy: (map['overallAccuracy'] ?? 0.0).toDouble(),
      averageScore: (map['averageScore'] ?? 0.0).toDouble(),
      currentStreak: map['currentStreak'] ?? 0,
      strongestCategory: map['strongestCategory'] ?? 'N/A',
      weakestCategory: map['weakestCategory'] ?? 'N/A',
      totalQuestionsAttempted: map['totalQuestionsAttempted'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalPoints: map['totalPoints'] ?? 0,
      coins: map['coins'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalTestsTaken': totalTestsTaken,
      'overallAccuracy': overallAccuracy,
      'averageScore': averageScore,
      'currentStreak': currentStreak,
      'strongestCategory': strongestCategory,
      'weakestCategory': weakestCategory,
      'totalQuestionsAttempted': totalQuestionsAttempted,
      'correctAnswers': correctAnswers,
      'totalPoints': totalPoints,
      'coins': coins,
    };
  }
}

class RecentActivity {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
  final int? score;
  final String? category;

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.score,
    this.category,
  });

  factory RecentActivity.fromMap(Map<String, dynamic> map) {
    return RecentActivity(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      score: map['score'],
      category: map['category'],
    );
  }
}

