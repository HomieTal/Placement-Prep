import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/coding_provider.dart';

class CodingListScreen extends ConsumerWidget {
  const CodingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final problemsAsync = ref.watch(codingProblemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coding Practice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: problemsAsync.when(
        data: (problems) {
          if (problems.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.code,
              title: 'No Coding Problems',
              subtitle: 'Check back later for new challenges',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: problems.length,
            itemBuilder: (context, index) {
              final problem = problems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CustomCard(
                  onTap: () {
                    ref.read(selectedProblemProvider.notifier).state = problem;
                    context.push('/coding/problem');
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(problem.difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: _getDifficultyColor(problem.difficulty),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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
                              problem.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildDifficultyBadge(problem.difficulty),
                                const SizedBox(width: 8),
                                if (problem.tags.isNotEmpty)
                                  Text(
                                    problem.tags.take(2).join(', '),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, size: 16, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                '${problem.points}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: LoadingWidget()),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(codingProblemsProvider),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    final color = _getDifficultyColor(difficulty);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
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

