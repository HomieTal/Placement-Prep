import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/leaderboard_model.dart';
import '../../data/services/leaderboard_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Leaderboard Service Provider
final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  return LeaderboardService();
});

// Global Leaderboard Provider
final globalLeaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return await service.getGlobalLeaderboard();
});

// College Leaderboard Provider
final collegeLeaderboardProvider = FutureProvider.family<List<LeaderboardEntry>, String>((ref, college) async {
  final service = ref.watch(leaderboardServiceProvider);
  return await service.getCollegeLeaderboard(college);
});

// User Rank Provider
final userRankProvider = FutureProvider<int>((ref) async {
  final authState = ref.watch(authProvider);
  final service = ref.watch(leaderboardServiceProvider);

  if (authState.user == null) return 0;
  return await service.getUserRank(authState.user!.uid);
});

// Selected Leaderboard Tab
enum LeaderboardTab { global, college }

final selectedLeaderboardTabProvider = StateProvider<LeaderboardTab>((ref) => LeaderboardTab.global);

