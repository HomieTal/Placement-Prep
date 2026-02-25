import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/services/dashboard_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Dashboard Service Provider
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

// Dashboard Stats Provider
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final authState = ref.watch(authProvider);
  final dashboardService = ref.watch(dashboardServiceProvider);

  if (authState.user == null) {
    return DashboardStats();
  }

  return await dashboardService.getDashboardStats(authState.user!.uid);
});

// Recent Activities Provider
final recentActivitiesProvider = FutureProvider<List<RecentActivity>>((ref) async {
  final authState = ref.watch(authProvider);
  final dashboardService = ref.watch(dashboardServiceProvider);

  if (authState.user == null) {
    return [];
  }

  return await dashboardService.getRecentActivities(authState.user!.uid);
});

// Dashboard State Notifier
class DashboardNotifier extends StateNotifier<AsyncValue<DashboardStats>> {
  final DashboardService _service;
  final String? _userId;

  DashboardNotifier(this._service, this._userId) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadStats();
    }
  }

  Future<void> loadStats() async {
    if (_userId == null) return;

    state = const AsyncValue.loading();
    try {
      final stats = await _service.getDashboardStats(_userId!);
      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await loadStats();
  }
}

// Dashboard Provider
final dashboardProvider = StateNotifierProvider<DashboardNotifier, AsyncValue<DashboardStats>>((ref) {
  final service = ref.watch(dashboardServiceProvider);
  final authState = ref.watch(authProvider);
  return DashboardNotifier(service, authState.user?.uid);
});

