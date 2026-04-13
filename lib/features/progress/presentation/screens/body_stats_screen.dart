import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/section_header.dart';
import '../../data/progress_repository.dart';
import '../../domain/body_measurement_model.dart';
import '../providers/progress_providers.dart';

class BodyStatsScreen extends ConsumerWidget {
  const BodyStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latest = ref.watch(latestMeasurementProvider);
    final weightTrend = ref.watch(bodyWeightTrendProvider);

    final currentWeight = latest?.weight ?? 0.0;
    final bodyFat = latest?.bodyFat ?? 0.0;

    // Build weight trend chart data
    final weightSpots = weightTrend.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value);
    }).toList();

    final minW = weightSpots.isEmpty ? 170.0 : weightSpots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxW = weightSpots.isEmpty ? 190.0 : weightSpots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Stats'),
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
            // Current stats
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      children: [
                        const Icon(Icons.monitor_weight_outlined,
                            color: AppColors.accent, size: 28),
                        const SizedBox(height: 8),
                        Text(currentWeight.toStringAsFixed(1),
                            style: AppTypography.statLarge),
                        Text('lbs', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    child: Column(
                      children: [
                        const Icon(Icons.percent,
                            color: AppColors.accentSecondary, size: 28),
                        const SizedBox(height: 8),
                        Text(bodyFat.toStringAsFixed(1),
                            style: AppTypography.statLarge),
                        Text('% body fat', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            AppButton.secondary(
              label: 'Log Measurements',
              icon: Icons.add,
              onPressed: () => _showLogMeasurementSheet(context, ref),
            ),
            const SizedBox(height: 24),

            // Weight trend chart
            const SectionHeader(title: 'Weight Trend'),
            const SizedBox(height: 12),
            AppCard(
              child: SizedBox(
                height: 200,
                child: weightSpots.isEmpty
                    ? const Center(child: Text('No data yet'))
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (v) => FlLine(
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
                                reservedSize: 36,
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
                                  if (idx < weightTrend.length) {
                                    final d = weightTrend[idx].key;
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
                          minY: minW,
                          maxY: maxW,
                          lineBarsData: [
                            LineChartBarData(
                              spots: weightSpots,
                              isCurved: true,
                              color: AppColors.accentSecondary,
                              barWidth: 3,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (_, __, ___, ____) =>
                                    FlDotCirclePainter(
                                  radius: 3,
                                  color: AppColors.accentSecondary,
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
                                    AppColors.accentSecondary
                                        .withValues(alpha: 0.2),
                                    AppColors.accentSecondary
                                        .withValues(alpha: 0.0),
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

            // Measurements from data
            const SectionHeader(title: 'Measurements'),
            const SizedBox(height: 12),
            if (latest != null)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.6,
                children: [
                  if (latest.chest != null)
                    _MeasurementCard(label: 'Chest', value: '${latest.chest!.toStringAsFixed(1)}"'),
                  if (latest.leftArm != null)
                    _MeasurementCard(label: 'Arms', value: '${latest.leftArm!.toStringAsFixed(1)}"'),
                  if (latest.waist != null)
                    _MeasurementCard(label: 'Waist', value: '${latest.waist!.toStringAsFixed(1)}"'),
                  if (latest.leftThigh != null)
                    _MeasurementCard(label: 'Thighs', value: '${latest.leftThigh!.toStringAsFixed(1)}"'),
                  if (latest.neck != null)
                    _MeasurementCard(label: 'Neck', value: '${latest.neck!.toStringAsFixed(1)}"'),
                  if (latest.leftCalf != null)
                    _MeasurementCard(label: 'Calves', value: '${latest.leftCalf!.toStringAsFixed(1)}"'),
                ],
              )
            else
              AppCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('No measurements yet', style: AppTypography.caption),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogMeasurementSheet(BuildContext context, WidgetRef ref) {
    final weightCtrl = TextEditingController();
    final bodyFatCtrl = TextEditingController();
    final chestCtrl = TextEditingController();
    final waistCtrl = TextEditingController();
    final hipsCtrl = TextEditingController();
    final armCtrl = TextEditingController();
    final thighCtrl = TextEditingController();
    final calfCtrl = TextEditingController();
    final neckCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppDimensions.padding2XL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.text3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Log Measurements', style: AppTypography.h2),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: weightCtrl,
                      label: 'Weight (lbs)',
                      hint: '0.0',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      controller: bodyFatCtrl,
                      label: 'Body Fat %',
                      hint: '0.0',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Body Measurements (inches)', style: AppTypography.caption),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: AppTextField(controller: chestCtrl, label: 'Chest', hint: '0.0', keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(controller: waistCtrl, label: 'Waist', hint: '0.0', keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: AppTextField(controller: hipsCtrl, label: 'Hips', hint: '0.0', keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(controller: neckCtrl, label: 'Neck', hint: '0.0', keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: AppTextField(controller: armCtrl, label: 'Arms', hint: '0.0', keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(controller: thighCtrl, label: 'Thighs', hint: '0.0', keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(controller: calfCtrl, label: 'Calves', hint: '0.0', keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              const SizedBox(height: 16),
              AppTextField(controller: notesCtrl, label: 'Notes', hint: 'Optional notes...', maxLines: 2),
              const SizedBox(height: 24),
              AppButton(
                label: 'Save Measurement',
                isFullWidth: true,
                onPressed: () {
                  double? tryParse(TextEditingController c) {
                    final v = double.tryParse(c.text.trim());
                    return (v != null && v > 0) ? v : null;
                  }

                  final measurement = BodyMeasurementModel(
                    id: 'meas_${DateTime.now().millisecondsSinceEpoch}',
                    date: DateTime.now(),
                    weight: tryParse(weightCtrl),
                    bodyFat: tryParse(bodyFatCtrl),
                    chest: tryParse(chestCtrl),
                    waist: tryParse(waistCtrl),
                    hips: tryParse(hipsCtrl),
                    leftArm: tryParse(armCtrl),
                    rightArm: tryParse(armCtrl),
                    leftThigh: tryParse(thighCtrl),
                    rightThigh: tryParse(thighCtrl),
                    leftCalf: tryParse(calfCtrl),
                    rightCalf: tryParse(calfCtrl),
                    neck: tryParse(neckCtrl),
                    notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  );

                  ref.read(progressRepositoryProvider).addBodyMeasurement(measurement);
                  ref.invalidate(bodyMeasurementsProvider);
                  ref.invalidate(latestMeasurementProvider);
                  ref.invalidate(bodyWeightTrendProvider);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final String label;
  final String value;

  const _MeasurementCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.stat),
        ],
      ),
    );
  }
}
