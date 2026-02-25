import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/dashboard_models.dart';
import '../providers/dashboard_provider.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class WelcomeCard extends StatelessWidget {
  final String userName;

  const WelcomeCard({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return CustomCard(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Keep up the great work!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ClipOval(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 72,
                width: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  final DashboardStats stats;
  final int crossAxisCount;

  const StatsGrid({
    super.key,
    required this.stats,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    final statItems = [
      {'title': 'Tests Taken', 'value': '${stats.totalTestsTaken}', 'icon': Icons.assignment, 'color': AppColors.primary},
      {'title': 'Accuracy', 'value': '${stats.overallAccuracy.toStringAsFixed(1)}%', 'icon': Icons.gps_fixed, 'color': AppColors.success},
      {'title': 'Avg Score', 'value': '${stats.averageScore.toStringAsFixed(1)}%', 'icon': Icons.trending_up, 'color': AppColors.accent},
      {'title': 'Streak', 'value': '${stats.currentStreak} days', 'icon': Icons.local_fire_department, 'color': AppColors.error},
      {'title': 'Strongest', 'value': stats.strongestCategory, 'icon': Icons.star, 'color': AppColors.secondary},
      {'title': 'Weakest', 'value': stats.weakestCategory, 'icon': Icons.warning, 'color': AppColors.warning},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: statItems.length,
      itemBuilder: (context, index) {
        final item = statItems[index];
        return StatCard(
          title: item['title'] as String,
          value: item['value'] as String,
          icon: item['icon'] as IconData,
          iconColor: item['color'] as Color,
        );
      },
    );
  }
}

class QuickAccessGrid extends StatelessWidget {
  final int crossAxisCount;

  const QuickAccessGrid({super.key, this.crossAxisCount = 2});

  @override
  Widget build(BuildContext context) {
    final features = [
      {'title': 'Aptitude', 'icon': Icons.calculate, 'route': '/preparation', 'color': AppColors.primary},
      {'title': 'Coding', 'icon': Icons.code, 'route': '/coding', 'color': AppColors.secondary},
      {'title': 'Mock Tests', 'icon': Icons.quiz, 'route': '/mock-tests', 'color': AppColors.accent},
      {'title': 'Interview Q&A', 'icon': Icons.question_answer, 'route': '/preparation', 'color': AppColors.info},
      {'title': 'Analytics', 'icon': Icons.analytics, 'route': '/analytics', 'color': AppColors.error},
      {'title': 'Leaderboard', 'icon': Icons.leaderboard, 'route': '/leaderboard', 'color': AppColors.warning},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return FeatureCard(
          title: feature['title'] as String,
          icon: feature['icon'] as IconData,
          color: feature['color'] as Color,
          onTap: () => context.push(feature['route'] as String),
        );
      },
    );
  }
}

class RecentActivityList extends ConsumerWidget {
  const RecentActivityList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(recentActivitiesProvider);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('View All'),
              ),
            ],
          ),
          const Divider(),
          activities.when(
            data: (list) {
              if (list.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text('No recent activity'),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length > 5 ? 5 : list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final activity = list[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getActivityIcon(activity.type),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      activity.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    subtitle: Text(
                      DateTimeUtils.getRelativeTime(activity.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: activity.score != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getScoreColor(activity.score!).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${activity.score}%',
                              style: TextStyle(
                                color: _getScoreColor(activity.score!),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : null,
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'test':
        return Icons.assignment;
      case 'practice':
        return Icons.school;
      case 'coding':
        return Icons.code;
      default:
        return Icons.check_circle;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }
}

class DashboardSidebar extends StatelessWidget {
  const DashboardSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    final menuItems = [
      {'title': 'Dashboard', 'icon': Icons.dashboard, 'route': '/dashboard'},
      {'title': 'Preparation', 'icon': Icons.school, 'route': '/preparation'},
      {'title': 'Mock Tests', 'icon': Icons.quiz, 'route': '/mock-tests'},
      {'title': 'Coding', 'icon': Icons.code, 'route': '/coding'},
      {'title': 'Analytics', 'icon': Icons.analytics, 'route': '/analytics'},
      {'title': 'Leaderboard', 'icon': Icons.leaderboard, 'route': '/leaderboard'},
    ];

    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'PlacementPrep',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = currentRoute == item['route'];

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item['icon'] as IconData,
                      color: isSelected ? AppColors.primary : null,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : null,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    onTap: () => context.go(item['route'] as String),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          // Logout
          const Divider(height: 1),
          Consumer(
            builder: (context, ref, _) => ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error)),
              onTap: () {
                ref.read(authProvider.notifier).signOut();
                context.go('/login');
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

