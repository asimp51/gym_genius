import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../providers/progress_providers.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';
import '../../../../core/widgets/ad_banner_widget.dart';
import '../../../../services/ad_service.dart';

class ProgressDashboardScreen extends ConsumerWidget {
  const ProgressDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimensions.padding2XL, AppDimensions.paddingLG,
                    AppDimensions.padding2XL, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Progress', style: AppTypography.h1),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusButton),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusButton),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: AppColors.text3,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Overview'),
                          Tab(text: 'Strength'),
                          Tab(text: 'Body'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    _OverviewTab(),
                    _StrengthTab(context),
                    _BodyTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _OverviewTab() {
    return Consumer(builder: (context, ref, _) {
      final weeklyVolume = ref.watch(weeklyVolumeProvider);
      final monthlyStats = ref.watch(monthlyStatsProvider);
      final workoutFreq = ref.watch(workoutFrequencyProvider);

      // Use weekly volume for the bar chart (last 7 entries or pad)
      final barData = weeklyVolume.length >= 7
          ? weeklyVolume.sublist(weeklyVolume.length - 7)
          : weeklyVolume;
      final maxVol = barData.isEmpty ? 1.0 : barData.reduce((a, b) => a > b ? a : b) * 1.2;

      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppDimensions.padding2XL, 0,
          AppDimensions.padding2XL, AppDimensions.bottomNavHeight + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weekly volume chart
            const SectionHeader(title: 'Weekly Volume'),
            const SizedBox(height: 12),
            AppCard(
              child: SizedBox(
                height: 200,
                child: barData.isEmpty
                    ? const Center(child: Text('No data yet'))
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: maxVol,
                          barGroups: List.generate(barData.length, (i) =>
                              _barGroup(i, barData[i])),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, _) => Text(
                                  '${(value / 1000).toInt()}k',
                                  style: AppTypography.caption.copyWith(fontSize: 10),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                  final idx = value.toInt();
                                  if (idx < days.length) {
                                    return Text(days[idx],
                                        style: AppTypography.caption.copyWith(fontSize: 10));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Ad banner for free tier users
            const AdBannerWidget(placement: AdPlacement.progressBanner),

            // Training frequency dots
            const SectionHeader(title: 'This Week'),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .asMap()
                    .entries
                    .map((entry) {
                  // Use workoutFreq if available
                  final trained = workoutFreq.isNotEmpty && entry.key < workoutFreq.length
                      ? workoutFreq[entry.key] > 0
                      : false;
                  return Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: trained
                              ? AppColors.accent
                              : AppColors.bgTertiary,
                          border: Border.all(
                            color: trained
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                        ),
                        child: trained
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(entry.value,
                          style: AppTypography.caption.copyWith(fontSize: 10)),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Monthly summary
            const SectionHeader(title: 'Monthly Summary'),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  _SummaryRow(
                      label: 'Workouts',
                      value: '${monthlyStats['workouts'] ?? 0}',
                      delta: '+${monthlyStats['workoutsDelta'] ?? 0}'),
                  const Divider(color: AppColors.border),
                  _SummaryRow(
                      label: 'Total Volume',
                      value: '${_fmtVol(monthlyStats['volume'] as double? ?? 0)} lbs',
                      delta: '${monthlyStats['volumeDelta'] ?? '+0%'}'),
                  const Divider(color: AppColors.border),
                  _SummaryRow(
                      label: 'Avg Duration',
                      value: '${monthlyStats['avgDuration'] ?? 0} min',
                      delta: '${monthlyStats['durationDelta'] ?? '+0%'}'),
                  const Divider(color: AppColors.border),
                  _SummaryRow(
                      label: 'PRs Set',
                      value: '${monthlyStats['prs'] ?? 0}',
                      delta: '+${monthlyStats['prsDelta'] ?? 0}'),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _StrengthTab(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.trending_up, size: 64, color: AppColors.accent),
            const SizedBox(height: 16),
            Text('Strength Progress', style: AppTypography.h2),
            const SizedBox(height: 8),
            Text(
              'Track your lifts and see your gains over time',
              style: AppTypography.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/strength-progress'),
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _BodyTab(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.monitor_weight_outlined,
                size: 64, color: AppColors.accentSecondary),
            const SizedBox(height: 16),
            Text('Body Stats', style: AppTypography.h2),
            const SizedBox(height: 8),
            Text(
              'Track your weight, measurements, and body composition',
              style: AppTypography.body.copyWith(color: AppColors.text2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/body-stats'),
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          gradient: y > 0 ? AppColors.gradient : null,
          color: y > 0 ? null : AppColors.bgTertiary,
        ),
      ],
    );
  }

  String _fmtVol(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final String delta;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.delta,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body.copyWith(color: AppColors.text2)),
          Row(
            children: [
              Text(value,
                  style:
                      AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  delta,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.success,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
