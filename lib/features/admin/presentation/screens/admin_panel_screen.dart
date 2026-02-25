import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/admin_provider.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final selectedTab = ref.watch(selectedAdminTabProvider);

    // Check if user is admin
    if (authState.user == null || !authState.user!.isAdmin) {
      return Scaffold(
        body: EmptyStateWidget(
          icon: Icons.lock,
          title: 'Access Denied',
          subtitle: 'You do not have admin privileges',
          buttonText: 'Go Back',
          onButtonPressed: () => context.go('/dashboard'),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Admin Sidebar
          _buildSidebar(context, ref, selectedTab),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(context, authState),
                // Content
                Expanded(
                  child: _buildContent(context, ref, selectedTab),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref, AdminTab selectedTab) {
    final menuItems = [
      {'tab': AdminTab.dashboard, 'title': 'Dashboard', 'icon': Icons.dashboard},
      {'tab': AdminTab.questions, 'title': 'Questions', 'icon': Icons.quiz},
      {'tab': AdminTab.mockTests, 'title': 'Mock Tests', 'icon': Icons.assignment},
      {'tab': AdminTab.coding, 'title': 'Coding', 'icon': Icons.code},
      {'tab': AdminTab.users, 'title': 'Users', 'icon': Icons.people},
    ];

    return Container(
      width: 250,
      color: AppColors.surfaceDark,
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
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                final isSelected = item['tab'] == selectedTab;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.2) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(
                      item['icon'] as IconData,
                      color: isSelected ? AppColors.primary : Colors.white70,
                    ),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : Colors.white70,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    onTap: () {
                      ref.read(selectedAdminTabProvider.notifier).state =
                          item['tab'] as AdminTab;
                    },
                  ),
                );
              },
            ),
          ),
          // Back to App
          const Divider(color: Colors.white24, height: 1),
          ListTile(
            leading: const Icon(Icons.arrow_back, color: Colors.white70),
            title: const Text('Back to App', style: TextStyle(color: Colors.white70)),
            onTap: () => context.go('/dashboard'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AuthState authState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Welcome, ${authState.user?.name ?? 'Admin'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              authState.user?.name.substring(0, 1).toUpperCase() ?? 'A',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, AdminTab selectedTab) {
    switch (selectedTab) {
      case AdminTab.dashboard:
        return _buildDashboardTab(context, ref);
      case AdminTab.questions:
        return _buildQuestionsTab(context, ref);
      case AdminTab.mockTests:
        return _buildMockTestsTab(context, ref);
      case AdminTab.coding:
        return _buildCodingTab(context, ref);
      case AdminTab.users:
        return _buildUsersTab(context, ref);
    }
  }

  Widget _buildDashboardTab(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(overallStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          statsAsync.when(
            data: (stats) => GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2,
              children: [
                _buildStatCard('Total Users', '${stats['totalUsers'] ?? 0}', Icons.people, AppColors.primary),
                _buildStatCard('Questions', '${stats['totalQuestions'] ?? 0}', Icons.quiz, AppColors.success),
                _buildStatCard('Mock Tests', '${stats['totalTests'] ?? 0}', Icons.assignment, AppColors.accent),
                _buildStatCard('Attempts', '${stats['totalAttempts'] ?? 0}', Icons.analytics, AppColors.info),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(title),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsTab(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(adminQuestionsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Questions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Show add question dialog
                  _showAddQuestionDialog(context, ref);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
              ),
            ],
          ),
        ),
        Expanded(
          child: questionsAsync.when(
            data: (questions) {
              if (questions.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.quiz,
                  title: 'No Questions',
                  subtitle: 'Add your first question',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  return CustomCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        question.question,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(
                        children: [
                          Chip(
                            label: Text(question.category, style: const TextStyle(fontSize: 10)),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(question.difficulty, style: const TextStyle(fontSize: 10)),
                            backgroundColor: _getDifficultyColor(question.difficulty).withOpacity(0.1),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Edit question
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.error),
                            onPressed: () {
                              // Delete question
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: LoadingWidget()),
            error: (e, _) => ErrorStateWidget(message: e.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildMockTestsTab(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(adminMockTestsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Mock Tests',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Show add test dialog
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Mock Test'),
              ),
            ],
          ),
        ),
        Expanded(
          child: testsAsync.when(
            data: (tests) {
              if (tests.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.assignment,
                  title: 'No Mock Tests',
                  subtitle: 'Create your first mock test',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: tests.length,
                itemBuilder: (context, index) {
                  final test = tests[index];
                  return CustomCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(test.title),
                      subtitle: Text('${test.totalQuestions} questions • ${test.durationMinutes} mins'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: test.isActive,
                            onChanged: (value) {
                              // Toggle active status
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.error),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: LoadingWidget()),
            error: (e, _) => ErrorStateWidget(message: e.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildCodingTab(BuildContext context, WidgetRef ref) {
    final problemsAsync = ref.watch(adminCodingProblemsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manage Coding Problems',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Show add problem dialog
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Problem'),
              ),
            ],
          ),
        ),
        Expanded(
          child: problemsAsync.when(
            data: (problems) {
              if (problems.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.code,
                  title: 'No Coding Problems',
                  subtitle: 'Add your first coding challenge',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: problems.length,
                itemBuilder: (context, index) {
                  final problem = problems[index];
                  return CustomCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(problem.title),
                      subtitle: Row(
                        children: [
                          Chip(
                            label: Text(problem.difficulty, style: const TextStyle(fontSize: 10)),
                            backgroundColor: _getDifficultyColor(problem.difficulty).withOpacity(0.1),
                            padding: EdgeInsets.zero,
                          ),
                          const SizedBox(width: 8),
                          Text('${problem.points} points'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.error),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: LoadingWidget()),
            error: (e, _) => ErrorStateWidget(message: e.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildUsersTab(BuildContext context, WidgetRef ref) {
    return Center(
      child: Text(
        'Users Management - Coming Soon',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }

  void _showAddQuestionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Question'),
        content: const SizedBox(
          width: 500,
          child: Text('Question form would go here'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Add question logic
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return AppColors.easy;
      case 'Medium':
        return AppColors.medium;
      case 'Hard':
        return AppColors.hard;
      default:
        return AppColors.primary;
    }
  }
}

