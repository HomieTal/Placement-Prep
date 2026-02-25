import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/mock_test_provider.dart';

class MockTestDetailsScreen extends ConsumerWidget {
  const MockTestDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final test = ref.watch(selectedTestProvider);

    if (test == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test Details')),
        body: const EmptyStateWidget(
          icon: Icons.quiz,
          title: 'No Test Selected',
          subtitle: 'Please select a test from the list',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(test.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/mock-tests'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Test Info Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.quiz,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            _buildDifficultyBadge(test.difficulty),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    test.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Test Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.help_outline,
                    '${test.totalQuestions}',
                    'Questions',
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.timer_outlined,
                    '${test.durationMinutes}',
                    'Minutes',
                    AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Categories
            Text(
              'Categories Covered',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: test.categories.map((category) {
                return Chip(
                  label: Text(category),
                  backgroundColor: AppColors.primary.withAlpha(25),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Instructions
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            CustomCard(
              color: AppColors.info.withAlpha(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstruction(context, '1', 'All questions are multiple choice with single correct answer'),
                  _buildInstruction(context, '2', 'You can navigate between questions using Previous/Next buttons'),
                  _buildInstruction(context, '3', 'Timer will auto-submit the test when time runs out'),
                  _buildInstruction(context, '4', 'You can review all questions before final submission'),
                  _buildInstruction(context, '5', 'Each correct answer awards points based on difficulty'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Start Button
            CustomButton(
              text: 'Start Test',
              onPressed: () {
                ref.read(testEngineProvider.notifier).startTest(test);
                context.go('/mock-tests/test');
              },
              icon: Icons.play_arrow,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return CustomCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction(BuildContext context, String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.info,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    switch (difficulty) {
      case 'Easy':
        color = AppColors.easy;
        break;
      case 'Hard':
        color = AppColors.hard;
        break;
      default:
        color = AppColors.medium;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

