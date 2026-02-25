import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_builder.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/analytics_provider.dart';
import '../../data/models/analytics_model.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(userAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: analyticsAsync.when(
        data: (analytics) => _buildAnalyticsContent(context, ref, analytics),
        loading: () => const Center(child: LoadingWidget(message: 'Loading analytics...')),
        error: (e, _) => ErrorStateWidget(
          message: e.toString(),
          onRetry: () => ref.refresh(userAnalyticsProvider),
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, WidgetRef ref, AnalyticsModel analytics) {
    return SingleChildScrollView(
      padding: ResponsivePadding.getScreenPadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCards(context, analytics),
          const SizedBox(height: 24),

          // Performance Over Time Chart
          _buildPerformanceChart(context, analytics),
          const SizedBox(height: 24),

          // Charts Row
          ResponsiveBuilder(
            mobile: Column(
              children: [
                _buildCategoryChart(context, analytics),
                const SizedBox(height: 24),
                _buildDifficultyChart(context, analytics),
              ],
            ),
            tablet: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCategoryChart(context, analytics)),
                const SizedBox(width: 24),
                Expanded(child: _buildDifficultyChart(context, analytics)),
              ],
            ),
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCategoryChart(context, analytics)),
                const SizedBox(width: 24),
                Expanded(child: _buildDifficultyChart(context, analytics)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Weekly Activity
          _buildWeeklyActivity(context, analytics),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, AnalyticsModel analytics) {
    return GridView.count(
      crossAxisCount: ResponsiveBuilder.isMobile(context) ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Overall Accuracy',
          value: '${analytics.overallAccuracy.toStringAsFixed(1)}%',
          icon: Icons.check_circle,
          iconColor: AppColors.success,
        ),
        StatCard(
          title: 'Average Score',
          value: '${analytics.averageScore.toStringAsFixed(1)}%',
          icon: Icons.score,
          iconColor: AppColors.primary,
        ),
        StatCard(
          title: 'Strongest',
          value: analytics.strongestCategory.length > 15
              ? '${analytics.strongestCategory.substring(0, 12)}...'
              : analytics.strongestCategory,
          icon: Icons.star,
          iconColor: AppColors.accent,
        ),
        StatCard(
          title: 'Improvement',
          value: '${analytics.improvementTrend >= 0 ? '+' : ''}${analytics.improvementTrend.toStringAsFixed(1)}%',
          icon: analytics.improvementTrend >= 0 ? Icons.trending_up : Icons.trending_down,
          iconColor: analytics.improvementTrend >= 0 ? AppColors.success : AppColors.error,
        ),
      ],
    );
  }

  Widget _buildPerformanceChart(BuildContext context, AnalyticsModel analytics) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Over Time',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: analytics.performanceHistory.isEmpty
                ? const Center(child: Text('No data available'))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= analytics.performanceHistory.length) {
                                return const SizedBox();
                              }
                              final date = analytics.performanceHistory[value.toInt()].date;
                              return Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: analytics.performanceHistory.length.toDouble() - 1,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: analytics.performanceHistory
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value.score))
                              .toList(),
                          isCurved: true,
                          color: AppColors.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context, AnalyticsModel analytics) {
    final categories = analytics.categoryStats.entries.toList();

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category-wise Accuracy',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: categories.isEmpty
                ? const Center(child: Text('No data available'))
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barGroups: categories.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.value.accuracy,
                              color: AppColors.chartColors[entry.key % AppColors.chartColors.length],
                              width: 20,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= categories.length) return const SizedBox();
                              final name = categories[value.toInt()].key;
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  name.length > 8 ? '${name.substring(0, 6)}..' : name,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChart(BuildContext context, AnalyticsModel analytics) {
    final difficulties = analytics.difficultyStats.entries.toList();
    final colors = [AppColors.easy, AppColors.medium, AppColors.hard];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Difficulty Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: difficulties.isEmpty
                ? const Center(child: Text('No data available'))
                : Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: difficulties.asMap().entries.map((entry) {
                              final total = difficulties.fold<int>(
                                0,
                                (sum, e) => sum + e.value.totalAttempts,
                              );
                              final percentage = total > 0
                                  ? (entry.value.value.totalAttempts / total * 100)
                                  : 0.0;
                              return PieChartSectionData(
                                value: entry.value.value.totalAttempts.toDouble(),
                                color: colors[entry.key % colors.length],
                                title: '${percentage.toStringAsFixed(0)}%',
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                radius: 60,
                              );
                            }).toList(),
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: difficulties.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: colors[entry.key % colors.length],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  entry.value.key,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyActivity(BuildContext context, AnalyticsModel analytics) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Study Activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: analytics.weeklyActivity.map((activity) {
              final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              final dayIndex = activity.date.weekday - 1;
              final maxActivity = analytics.weeklyActivity
                  .map((a) => a.totalActivity)
                  .fold(1, (a, b) => a > b ? a : b);
              final intensity = activity.totalActivity / maxActivity;

              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1 + intensity * 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${activity.questionsAttempted}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: intensity > 0.5 ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dayNames[dayIndex],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Less', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 8),
              ...List.generate(5, (index) {
                return Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1 + index * 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              const SizedBox(width: 8),
              const Text('More', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

