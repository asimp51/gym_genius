import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../domain/b2b_models.dart';
import '../providers/b2b_providers.dart';

class OrgAnalyticsScreen extends ConsumerStatefulWidget {
  const OrgAnalyticsScreen({super.key});

  @override
  ConsumerState<OrgAnalyticsScreen> createState() =>
      _OrgAnalyticsScreenState();
}

class _OrgAnalyticsScreenState extends ConsumerState<OrgAnalyticsScreen> {
  String _dateRange = 'This Month';

  @override
  Widget build(BuildContext context) {
    final orgAsync = ref.watch(currentOrganizationProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        title: Text('Analytics', style: AppTypography.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined,
                color: AppColors.text2),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Analytics report exported'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            tooltip: 'Export',
          ),
        ],
      ),
      body: orgAsync.when(
        data: (org) {
          if (org == null) return const Center(child: Text('No org'));
          return _AnalyticsBody(
            org: org,
            dateRange: _dateRange,
            onDateRangeChanged: (val) =>
                setState(() => _dateRange = val),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AnalyticsBody extends ConsumerWidget {
  final Organization org;
  final String dateRange;
  final ValueChanged<String> onDateRangeChanged;

  const _AnalyticsBody({
    required this.org,
    required this.dateRange,
    required this.onDateRangeChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(orgAnalyticsProvider(org.id));

    return analyticsAsync.when(
      data: (analytics) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date range selector
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  'This Week',
                  'This Month',
                  'This Quarter',
                  'All Time'
                ]
                    .map((range) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => onDateRangeChanged(range),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: dateRange == range
                                    ? AppColors.accent
                                    : AppColors.bgSecondary,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: dateRange == range
                                      ? AppColors.accent
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(range,
                                  style: AppTypography.caption.copyWith(
                                    color: dateRange == range
                                        ? Colors.white
                                        : AppColors.text2,
                                  )),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),

            // KPI Cards
            Row(
              children: [
                Expanded(
                    child: _KpiCard(
                        'Total Workouts',
                        '${analytics.totalWorkoutsThisMonth}',
                        Icons.fitness_center,
                        AppColors.accent)),
                const SizedBox(width: 12),
                Expanded(
                    child: _KpiCard(
                        'Avg Per Member',
                        analytics.avgWorkoutsPerWeek.toStringAsFixed(1),
                        Icons.person,
                        AppColors.accentSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _KpiCard(
                        'Retention',
                        '${analytics.retentionRate.toStringAsFixed(0)}%',
                        Icons.trending_up,
                        AppColors.success)),
                const SizedBox(width: 12),
                Expanded(
                    child: _KpiCard(
                        'Growth',
                        '+${analytics.newMembersThisMonth}',
                        Icons.group_add,
                        AppColors.warning)),
              ],
            ),
            const SizedBox(height: 24),

            // Workouts by Day Bar Chart (fl_chart)
            Text('Workouts by Day', style: AppTypography.h3),
            const SizedBox(height: 12),
            Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: _WorkoutBarChart(
                  workoutsByDay: analytics.workoutsByDay),
            ),
            const SizedBox(height: 24),

            // Member Growth Line Chart
            Text('Member Growth', style: AppTypography.h3),
            const SizedBox(height: 12),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusCard),
                border: Border.all(color: AppColors.border),
              ),
              child: _MemberGrowthChart(
                  totalMembers: analytics.totalMembers),
            ),
            const SizedBox(height: 24),

            // Top Exercises
            Text('Top Exercises', style: AppTypography.h3),
            const SizedBox(height: 12),
            _TopExercisesChart(),
            const SizedBox(height: 24),

            // Program Completion
            Text('Program Completion Rates', style: AppTypography.h3),
            const SizedBox(height: 12),
            _ProgramCompletionSection(
                completionRate: analytics.avgCompletionRate),
            const SizedBox(height: 24),

            // Activity Heatmap
            Text('Member Activity Heatmap', style: AppTypography.h3),
            const SizedBox(height: 12),
            _ActivityHeatmap(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _KpiCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: AppTypography.statLarge.copyWith(fontSize: 22)),
          const SizedBox(height: 2),
          Text(title,
              style: AppTypography.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

class _WorkoutBarChart extends StatelessWidget {
  final Map<String, int> workoutsByDay;
  const _WorkoutBarChart({required this.workoutsByDay});

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxY = workoutsByDay.values
            .fold<int>(0, (prev, e) => e > prev ? e : prev)
            .toDouble() *
        1.2;

    return BarChart(
      BarChartData(
        maxY: maxY > 0 ? maxY : 50,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${days[group.x.toInt()]}\n${rod.toY.toInt()} workouts',
                AppTypography.caption.copyWith(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= days.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(days[idx],
                      style: AppTypography.caption
                          .copyWith(fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}',
                    style:
                        AppTypography.caption.copyWith(fontSize: 9));
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 4 : 10,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border,
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(days.length, (index) {
          final val =
              (workoutsByDay[days[index]] ?? 0).toDouble();
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: val,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.accent, AppColors.accentSecondary],
                ),
                width: 20,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _MemberGrowthChart extends StatelessWidget {
  final int totalMembers;
  const _MemberGrowthChart({required this.totalMembers});

  @override
  Widget build(BuildContext context) {
    // Simulated growth data
    final spots = <FlSpot>[
      FlSpot(0, (totalMembers * 0.3).toDouble()),
      FlSpot(1, (totalMembers * 0.4).toDouble()),
      FlSpot(2, (totalMembers * 0.5).toDouble()),
      FlSpot(3, (totalMembers * 0.6).toDouble()),
      FlSpot(4, (totalMembers * 0.7).toDouble()),
      FlSpot(5, (totalMembers * 0.85).toDouble()),
      FlSpot(6, totalMembers.toDouble()),
    ];
    final months = ['Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${months[s.x.toInt()]}: ${s.y.toInt()} members',
                      AppTypography.caption
                          .copyWith(color: Colors.white),
                    ))
                .toList(),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: totalMembers / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border,
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= months.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(months[idx],
                      style: AppTypography.caption
                          .copyWith(fontSize: 10)),
                );
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text('${value.toInt()}',
                    style:
                        AppTypography.caption.copyWith(fontSize: 9));
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: totalMembers * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [AppColors.success, AppColors.accentSecondary],
            ),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 3,
                color: AppColors.success,
                strokeColor: AppColors.bgSecondary,
                strokeWidth: 2,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.success.withOpacity(0.3),
                  AppColors.success.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopExercisesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final exercises = [
      _ExerciseEntry('Bench Press', 87),
      _ExerciseEntry('Squats', 76),
      _ExerciseEntry('Deadlift', 68),
      _ExerciseEntry('Overhead Press', 54),
      _ExerciseEntry('Barbell Row', 49),
      _ExerciseEntry('Pull-ups', 42),
    ];
    final maxVal = exercises.first.count;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: exercises.map((ex) {
          final ratio = ex.count / maxVal;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(ex.name,
                      style: AppTypography.caption
                          .copyWith(fontSize: 12)),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.bgTertiary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: ratio,
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accent,
                                AppColors.accentSecondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 30,
                  child: Text('${ex.count}',
                      style: AppTypography.caption
                          .copyWith(fontSize: 11),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExerciseEntry {
  final String name;
  final int count;
  const _ExerciseEntry(this.name, this.count);
}

class _ProgramCompletionSection extends StatelessWidget {
  final double completionRate;
  const _ProgramCompletionSection({required this.completionRate});

  @override
  Widget build(BuildContext context) {
    final programs = [
      _ProgramCompletion('Strength Foundation', 85),
      _ProgramCompletion('Lean & Fit 6-Week', 78),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: programs.map((p) {
          final color = p.rate >= 80
              ? AppColors.success
              : p.rate >= 60
                  ? AppColors.warning
                  : AppColors.error;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(p.name,
                            style: AppTypography.body
                                .copyWith(fontSize: 13))),
                    Text('${p.rate}%',
                        style: AppTypography.stat.copyWith(
                            fontSize: 14, color: color)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: p.rate / 100,
                    backgroundColor: AppColors.bgTertiary,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProgramCompletion {
  final String name;
  final int rate;
  const _ProgramCompletion(this.name, this.rate);
}

class _ActivityHeatmap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 4 weeks x 7 days
    final data = [
      [3, 5, 2, 4, 3, 1, 0],
      [4, 3, 1, 5, 4, 2, 1],
      [5, 4, 3, 4, 5, 3, 0],
      [4, 6, 2, 5, 3, 2, 1],
    ];
    final maxVal =
        data.expand((w) => w).fold<int>(0, (p, e) => e > p ? e : p);
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day labels
          Row(
            children: [
              const SizedBox(width: 40),
              ...dayLabels.map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: AppTypography.caption
                              .copyWith(fontSize: 10)),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 6),
          ...List.generate(data.length, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text('W${weekIndex + 1}',
                        style: AppTypography.caption
                            .copyWith(fontSize: 10)),
                  ),
                  ...List.generate(7, (dayIndex) {
                    final val = data[weekIndex][dayIndex];
                    final intensity =
                        maxVal > 0 ? val / maxVal : 0.0;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: intensity == 0
                                  ? AppColors.bgTertiary
                                  : AppColors.accent
                                      .withOpacity(0.2 + intensity * 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Text(
                                '$val',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 9,
                                  color: intensity > 0.5
                                      ? Colors.white
                                      : AppColors.text3,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less',
                  style: AppTypography.caption.copyWith(fontSize: 9)),
              const SizedBox(width: 4),
              ...List.generate(5, (i) {
                final opacity = i == 0 ? 0.0 : 0.2 + (i / 4) * 0.8;
                return Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: i == 0
                        ? AppColors.bgTertiary
                        : AppColors.accent.withOpacity(opacity),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
              const SizedBox(width: 4),
              Text('More',
                  style: AppTypography.caption.copyWith(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}
