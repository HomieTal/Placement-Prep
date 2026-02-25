import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_builder.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final dashboardStats = ref.watch(dashboardStatsProvider);

    return ResponsiveBuilder(
      mobile: _MobileDashboard(authState: authState, dashboardStats: dashboardStats),
      tablet: _TabletDashboard(authState: authState, dashboardStats: dashboardStats),
      desktop: _DesktopDashboard(authState: authState, dashboardStats: dashboardStats),
    );
  }
}

class _MobileDashboard extends StatelessWidget {
  final AuthState authState;
  final AsyncValue dashboardStats;

  const _MobileDashboard({
    required this.authState,
    required this.dashboardStats,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              WelcomeCard(userName: authState.user?.name ?? 'Student'),
              const SizedBox(height: 24),

              // Stats Grid
              dashboardStats.when(
                data: (stats) => StatsGrid(stats: stats),
                loading: () => const LoadingWidget(),
                error: (e, _) => ErrorStateWidget(message: e.toString()),
              ),
              const SizedBox(height: 24),

              // Quick Access Section
              Text(
                'Quick Access',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const QuickAccessGrid(),
              const SizedBox(height: 24),

              // Recent Activity
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const RecentActivityList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabletDashboard extends StatelessWidget {
  final AuthState authState;
  final AsyncValue dashboardStats;

  const _TabletDashboard({
    required this.authState,
    required this.dashboardStats,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeCard(userName: authState.user?.name ?? 'Student'),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      dashboardStats.when(
                        data: (stats) => StatsGrid(stats: stats, crossAxisCount: 3),
                        loading: () => const LoadingWidget(),
                        error: (e, _) => ErrorStateWidget(message: e.toString()),
                      ),
                      const SizedBox(height: 24),
                      const QuickAccessGrid(crossAxisCount: 3),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                const Expanded(
                  flex: 1,
                  child: RecentActivityList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopDashboard extends StatelessWidget {
  final AuthState authState;
  final AsyncValue dashboardStats;

  const _DesktopDashboard({
    required this.authState,
    required this.dashboardStats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        const DashboardSidebar(),
        // Main Content
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    authState.user?.name.substring(0, 1).toUpperCase() ?? 'S',
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeCard(userName: authState.user?.name ?? 'Student'),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            dashboardStats.when(
                              data: (stats) => StatsGrid(stats: stats, crossAxisCount: 4),
                              loading: () => const LoadingWidget(),
                              error: (e, _) => ErrorStateWidget(message: e.toString()),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Quick Access',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            const QuickAccessGrid(crossAxisCount: 6),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      const Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RecentActivityList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

