import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/preparation_provider.dart';

class PreparationScreen extends ConsumerWidget {
  const PreparationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preparation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a Category',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a category to start practicing',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 24),
            _buildCategoryGrid(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, WidgetRef ref) {
    final categories = [
      {
        'name': 'Quantitative Aptitude',
        'icon': Icons.calculate,
        'color': AppColors.primary,
        'description': 'Numbers, Algebra, Geometry'
      },
      {
        'name': 'Logical Reasoning',
        'icon': Icons.psychology,
        'color': AppColors.secondary,
        'description': 'Puzzles, Patterns, Deductions'
      },
      {
        'name': 'Verbal Ability',
        'icon': Icons.text_fields,
        'color': AppColors.accent,
        'description': 'Grammar, Vocabulary, Reading'
      },
      {
        'name': 'Programming - C',
        'icon': Icons.code,
        'color': AppColors.info,
        'description': 'Basics, Pointers, Arrays'
      },
      {
        'name': 'Programming - C++',
        'icon': Icons.code,
        'color': AppColors.error,
        'description': 'OOP, STL, Templates'
      },
      {
        'name': 'Programming - Java',
        'icon': Icons.coffee,
        'color': AppColors.warning,
        'description': 'Collections, Multithreading'
      },
      {
        'name': 'Programming - Python',
        'icon': Icons.pest_control,
        'color': AppColors.success,
        'description': 'Basics, Libraries, OOP'
      },
      {
        'name': 'Data Structures',
        'icon': Icons.account_tree,
        'color': Colors.purple,
        'description': 'Arrays, Trees, Graphs'
      },
      {
        'name': 'SQL',
        'icon': Icons.storage,
        'color': Colors.teal,
        'description': 'Queries, Joins, Indexes'
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(
          name: category['name'] as String,
          icon: category['icon'] as IconData,
          color: category['color'] as Color,
          description: category['description'] as String,
          onTap: () {
            ref.read(selectedCategoryProvider.notifier).state = category['name'] as String;
            context.push('/preparation/practice');
          },
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

