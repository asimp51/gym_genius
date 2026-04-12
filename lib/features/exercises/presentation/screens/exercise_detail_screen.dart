import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../providers/exercise_provider.dart';
import '../../../progress/presentation/providers/progress_providers.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final String? exerciseId;

  const ExerciseDetailScreen({super.key, this.exerciseId});

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = exerciseId ??
        (ModalRoute.of(context)?.settings.arguments as String?) ??
        '';
    final exercise = ref.watch(exerciseByIdProvider(id));

    if (exercise == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Exercise'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Exercise not found')),
      );
    }

    final pr = ref.watch(exercisePRProvider(id));
    final rmHistory = ref.watch(exercise1RMHistoryProvider(id));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(exercise.name),
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
              // Illustration container
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fitness_center,
                        size: 64, color: AppColors.accent),
                    const SizedBox(height: 8),
                    Text(exercise.name,
                        style: AppTypography.h3),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Muscle group chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [...exercise.primaryMuscles, ...exercise.secondaryMuscles].map((m) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                    child: Text(
                      m,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.accent),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              // Equipment row
              Row(
                children: [
                  const Icon(Icons.fitness_center,
                      size: 16, color: AppColors.text3),
                  const SizedBox(width: 6),
                  Text(exercise.equipment.join(', '),
                      style: AppTypography.caption),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _capitalize(exercise.difficulty),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warning,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusButton),
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusButton),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.text3,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Instructions'),
                    Tab(text: 'History'),
                    Tab(text: 'Records'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 400,
                child: TabBarView(
                  children: [
                    _InstructionsTab(instructions: exercise.instructions),
                    _HistoryTab(history: rmHistory),
                    _RecordsTab(pr: pr),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionsTab extends StatelessWidget {
  final List<String> instructions;

  const _InstructionsTab({required this.instructions});

  @override
  Widget build(BuildContext context) {
    if (instructions.isEmpty) {
      return const Center(child: Text('No instructions available'));
    }
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: instructions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(instructions[index], style: AppTypography.body),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final List<MapEntry<DateTime, double>> history;

  const _HistoryTab({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text('No history yet'));
    }
    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 16,
        headingRowColor: WidgetStateProperty.all(AppColors.bgTertiary),
        dataRowColor: WidgetStateProperty.all(Colors.transparent),
        columns: const [
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Est. 1RM')),
        ],
        rows: history.take(10)
            .map((entry) => DataRow(cells: [
                  DataCell(Text(
                      '${entry.key.month}/${entry.key.day}',
                      style: AppTypography.caption)),
                  DataCell(Text('${entry.value.toStringAsFixed(0)} lbs',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.text1))),
                ]))
            .toList(),
      ),
    );
  }
}

class _RecordsTab extends StatelessWidget {
  final dynamic pr;

  const _RecordsTab({required this.pr});

  @override
  Widget build(BuildContext context) {
    if (pr == null) {
      return const Center(child: Text('No records yet'));
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: '1RM',
                value: pr.estimated1rm != null
                    ? '${pr.estimated1rm!.value.toStringAsFixed(0)} lbs'
                    : '--',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                label: 'Max Weight',
                value: pr.maxWeight != null
                    ? '${pr.maxWeight!.value.toStringAsFixed(0)} lbs'
                    : '--',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'Max Volume',
                value: pr.maxVolume != null
                    ? '${pr.maxVolume!.value.toStringAsFixed(0)}'
                    : '--',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                label: 'Max Reps',
                value: pr.maxReps != null
                    ? '${pr.maxReps!.value}'
                    : '--',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
