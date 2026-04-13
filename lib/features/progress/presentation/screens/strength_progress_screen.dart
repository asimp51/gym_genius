import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../providers/progress_providers.dart';
import '../../../exercises/presentation/providers/exercise_provider.dart';

class StrengthProgressScreen extends ConsumerStatefulWidget {
  const StrengthProgressScreen({super.key});

  @override
  ConsumerState<StrengthProgressScreen> createState() =>
      _StrengthProgressScreenState();
}

class _StrengthProgressScreenState extends ConsumerState<StrengthProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final allExercises = ref.watch(allExercisesProvider);
    final selectedExId = ref.watch(selectedProgressExerciseProvider);
    final rmHistory = ref.watch(exercise1RMHistoryProvider(selectedExId));
    final pr = ref.watch(exercisePRProvider(selectedExId));

    // Build dropdown items from real exercises
    final dropdownItems = allExercises
        .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
        .toList();

    // Build chart data from 1RM history
    final spots = rmHistory.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final minY = spots.isEmpty ? 0.0 : spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.9;
    final maxY = spots.isEmpty ? 100.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Strength Progress'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusButton),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownItems.any((d) => d.value == selectedExId)
                      ? selectedExId
                      : (dropdownItems.isNotEmpty ? dropdownItems.first.value : null),
                  isExpanded: true,
                  dropdownColor: AppColors.bgSecondary,
                  style: AppTypography.body,
                  items: dropdownItems,
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(selectedProgressExerciseProvider.notifier).state = v;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 1RM Progression chart
            const SectionHeader(title: 'Estimated 1RM'),
            const SizedBox(height: 12),
            AppCard(
              child: SizedBox(
                height: 220,
                child: spots.isEmpty
                    ? const Center(child: Text('No data yet'))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: AppColors.border,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (v, _) => Text(
                                  '${v.toInt()}',
                                  style: AppTypography.caption
                                      .copyWith(fontSize: 10),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  final idx = v.toInt();
                                  if (idx < rmHistory.length) {
                                    final d = rmHistory[idx].key;
                                    return Text('${d.month}/${d.day}',
                                        style: AppTypography.caption
                                            .copyWith(fontSize: 8));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: minY,
                          maxY: maxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              gradient: AppColors.gradient,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (_, __, ___, ____) =>
                                    FlDotCirclePainter(
                                  radius: 4,
                                  color: AppColors.accent,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                ),
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.accent.withValues(alpha: 0.3),
                                    AppColors.accent.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // PR Stats
            if (pr != null) ...[
              const SectionHeader(title: 'Personal Records'),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.all(AppDimensions.paddingSM),
                child: Column(
                  children: [
                    if (pr.estimated1rm != null)
                      _statRow('Est. 1RM', '${pr.estimated1rm!.value.toStringAsFixed(0)} lbs'),
                    if (pr.maxWeight != null)
                      _statRow('Max Weight', '${pr.maxWeight!.value.toStringAsFixed(0)} lbs'),
                    if (pr.maxVolume != null)
                      _statRow('Max Volume', '${pr.maxVolume!.value.toStringAsFixed(0)} lbs'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(value,
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
