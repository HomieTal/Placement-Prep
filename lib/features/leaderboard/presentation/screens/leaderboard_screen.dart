import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/leaderboard_provider.dart';
import '../../data/models/leaderboard_model.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedLeaderboardTabProvider);
    final authState = ref.watch(authProvider);
    final userRankAsync = ref.watch(userRankProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Column(
        children: [
          // User Rank Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomCard(
              gradient: AppColors.primaryGradient,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        authState.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.name ?? 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${authState.user?.totalPoints ?? 0} points',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      userRankAsync.when(
                        data: (rank) => Text(
                          '#$rank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        error: (_, __) => const Text(
                          '-',
                          style: TextStyle(color: Colors.white, fontSize: 28),
                        ),
                      ),
                      const Text(
                        'Your Rank',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    context,
                    ref,
                    'Global',
                    LeaderboardTab.global,
                    selectedTab,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTabButton(
                    context,
                    ref,
                    'College',
                    LeaderboardTab.college,
                    selectedTab,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Leaderboard List
          Expanded(
            child: selectedTab == LeaderboardTab.global
                ? _buildGlobalLeaderboard(context, ref)
                : _buildCollegeLeaderboard(context, ref, authState.user?.college),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    LeaderboardTab tab,
    LeaderboardTab selectedTab,
  ) {
    final isSelected = tab == selectedTab;
    return InkWell(
      onTap: () {
        ref.read(selectedLeaderboardTabProvider.notifier).state = tab;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalLeaderboard(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(globalLeaderboardProvider);

    return leaderboardAsync.when(
      data: (entries) => _buildLeaderboardList(context, entries),
      loading: () => const Center(child: LoadingWidget()),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => ref.refresh(globalLeaderboardProvider),
      ),
    );
  }

  Widget _buildCollegeLeaderboard(BuildContext context, WidgetRef ref, String? college) {
    if (college == null || college.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.school,
        title: 'College Not Set',
        subtitle: 'Update your profile to see college rankings',
      );
    }

    final leaderboardAsync = ref.watch(collegeLeaderboardProvider(college));

    return leaderboardAsync.when(
      data: (entries) => _buildLeaderboardList(context, entries),
      loading: () => const Center(child: LoadingWidget()),
      error: (e, _) => ErrorStateWidget(
        message: e.toString(),
        onRetry: () => ref.refresh(collegeLeaderboardProvider(college)),
      ),
    );
  }

  Widget _buildLeaderboardList(BuildContext context, List<LeaderboardEntry> entries) {
    if (entries.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.leaderboard,
        title: 'No Rankings Yet',
        subtitle: 'Complete tests to appear on the leaderboard',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildLeaderboardItem(context, entry);
      },
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, LeaderboardEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 40,
              child: entry.rank <= 3
                  ? _buildMedal(entry.rank)
                  : Text(
                      '#${entry.rank}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondaryLight,
                          ),
                      textAlign: TextAlign.center,
                    ),
            ),
            const SizedBox(width: 12),

            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: entry.photoUrl != null
                  ? NetworkImage(entry.photoUrl!)
                  : null,
              child: entry.photoUrl == null
                  ? Text(
                      entry.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Name and College
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (entry.college != null)
                    Text(
                      entry.college!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Points
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.totalPoints}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
                const Text(
                  'points',
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedal(int rank) {
    IconData icon;
    Color color;

    switch (rank) {
      case 1:
        icon = Icons.emoji_events;
        color = const Color(0xFFFFD700);
        break;
      case 2:
        icon = Icons.emoji_events;
        color = const Color(0xFFC0C0C0);
        break;
      case 3:
        icon = Icons.emoji_events;
        color = const Color(0xFFCD7F32);
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 28);
  }
}

