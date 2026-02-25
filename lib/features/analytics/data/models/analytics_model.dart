import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsModel {
  final String userId;
  final List<PerformanceData> performanceHistory;
  final Map<String, CategoryStats> categoryStats;
  final Map<String, DifficultyStats> difficultyStats;
  final List<WeeklyActivity> weeklyActivity;
  final double overallAccuracy;
  final double averageScore;
  final String strongestCategory;
  final String weakestCategory;
  final double improvementTrend;

  AnalyticsModel({
    required this.userId,
    this.performanceHistory = const [],
    this.categoryStats = const {},
    this.difficultyStats = const {},
    this.weeklyActivity = const [],
    this.overallAccuracy = 0.0,
    this.averageScore = 0.0,
    this.strongestCategory = 'N/A',
    this.weakestCategory = 'N/A',
    this.improvementTrend = 0.0,
  });
}

class PerformanceData {
  final DateTime date;
  final double score;
  final String category;
  final String type;

  PerformanceData({
    required this.date,
    required this.score,
    required this.category,
    required this.type,
  });

  factory PerformanceData.fromMap(Map<String, dynamic> map) {
    return PerformanceData(
      date: (map['date'] as Timestamp).toDate(),
      score: (map['score'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      type: map['type'] ?? 'test',
    );
  }
}

class CategoryStats {
  final String category;
  final int totalAttempts;
  final int correctAnswers;
  final double accuracy;
  final List<double> scores;

  CategoryStats({
    required this.category,
    this.totalAttempts = 0,
    this.correctAnswers = 0,
    this.accuracy = 0.0,
    this.scores = const [],
  });

  double get averageScore => scores.isNotEmpty
      ? scores.reduce((a, b) => a + b) / scores.length
      : 0.0;
}

class DifficultyStats {
  final String difficulty;
  final int totalAttempts;
  final int correctAnswers;
  final double accuracy;

  DifficultyStats({
    required this.difficulty,
    this.totalAttempts = 0,
    this.correctAnswers = 0,
    this.accuracy = 0.0,
  });
}

class WeeklyActivity {
  final DateTime date;
  final int questionsAttempted;
  final int testsCompleted;
  final int codingProblems;
  final int studyMinutes;

  WeeklyActivity({
    required this.date,
    this.questionsAttempted = 0,
    this.testsCompleted = 0,
    this.codingProblems = 0,
    this.studyMinutes = 0,
  });

  int get totalActivity => questionsAttempted + testsCompleted * 10 + codingProblems * 5;
}

class RankData {
  final int currentRank;
  final int previousRank;
  final int totalUsers;
  final List<RankHistory> rankHistory;

  RankData({
    this.currentRank = 0,
    this.previousRank = 0,
    this.totalUsers = 0,
    this.rankHistory = const [],
  });

  int get rankChange => previousRank - currentRank;
  bool get isImproved => rankChange > 0;
}

class RankHistory {
  final DateTime date;
  final int rank;

  RankHistory({
    required this.date,
    required this.rank,
  });
}

