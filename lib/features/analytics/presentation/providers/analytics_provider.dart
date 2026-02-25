import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analytics_model.dart';
import '../../data/services/analytics_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Analytics Service Provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

// User Analytics Provider
final userAnalyticsProvider = FutureProvider<AnalyticsModel>((ref) async {
  final authState = ref.watch(authProvider);
  final service = ref.watch(analyticsServiceProvider);

  if (authState.user == null) {
    return AnalyticsModel(userId: '');
  }

  return await service.getUserAnalytics(authState.user!.uid);
});

// Rank Data Provider
final rankDataProvider = FutureProvider<RankData>((ref) async {
  final authState = ref.watch(authProvider);
  final service = ref.watch(analyticsServiceProvider);

  if (authState.user == null) {
    return RankData();
  }

  return await service.getRankData(authState.user!.uid);
});

// Selected Time Range Provider
enum TimeRange { week, month, threeMonths, year, all }

final selectedTimeRangeProvider = StateProvider<TimeRange>((ref) => TimeRange.month);

