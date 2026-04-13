import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../providers/active_workout_provider.dart';
import '../../../exercises/presentation/providers/exercise_provider.dart';
import '../../../wearables/presentation/widgets/heart_rate_widget.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  void _showAddExerciseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _ExercisePickerSheet(
        onSelect: (exercise) {
          ref.read(activeWorkoutProvider.notifier).addExercise(exercise);
          Navigator.pop(ctx);
        },
        ref: ref,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeWorkoutProvider);
    final notifier = ref.read(activeWorkoutProvider.notifier);

    if (!state.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final totalSets = state.exercises.fold<int>(
        0, (sum, e) => sum + e.sets.length);
    final completedSets = state.exercises.fold<int>(
        0, (sum, e) => sum + e.sets.where((s) => s.isCompleted).length);
    final progress = totalSets > 0 ? completedSets / totalSets : 0.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.bgSecondary,
              title: Text('End Workout?', style: AppTypography.h2),
              content: Text(
                'Your progress will be lost if you leave now.',
                style: AppTypography.body.copyWith(color: AppColors.text2),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    notifier.discardWorkout();
                    context.go('/home');
                  },
                  child: Text('End',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(state.name),
              leading: IconButton(
                icon: const Icon(Icons.close, size: 22),
                onPressed: () => Navigator.maybePop(context),
              ),
              actions: [
                // Heart Rate (compact, from wearable)
                const HeartRateWidget(compact: true),
                const SizedBox(width: 6),
                // Timer
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.bgTertiary,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusPill),
                  ),
                  child: Text(
                    notifier.formattedTime,
                    style: AppTypography.stat.copyWith(
                      color: AppColors.accent,
                      fontSize: 16,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final workout = await notifier.finishWorkout();
                    if (context.mounted) {
                      context.go('/workout-summary', extra: workout);
                    }
                  },
                  child: Text(
                    'Finish',
                    style: AppTypography.button
                        .copyWith(color: AppColors.success),
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.padding2XL, vertical: 8),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$completedSets / $totalSets sets completed',
                            style: AppTypography.caption,
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.accent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.bgTertiary,
                          color: AppColors.accent,
                          minHeight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Exercise blocks
                Expanded(
                  child: state.exercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.fitness_center,
                                  size: 48, color: AppColors.text3),
                              const SizedBox(height: 12),
                              Text('Add an exercise to get started',
                                  style: AppTypography.body
                                      .copyWith(color: AppColors.text3)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.padding2XL,
                            8,
                            AppDimensions.padding2XL,
                            100,
                          ),
                          itemCount: state.exercises.length,
                          itemBuilder: (context, exIdx) {
                            final exercise = state.exercises[exIdx];
                            final allDone =
                                exercise.sets.every((s) => s.isCompleted);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.bgSecondary,
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusCard),
                                  border: Border(
                                    left: BorderSide(
                                      color: allDone
                                          ? AppColors.success
                                          : exIdx == state.currentExerciseIndex
                                              ? AppColors.accent
                                              : AppColors.text3,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                padding: const EdgeInsets.all(
                                    AppDimensions.paddingLG),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => notifier.toggleExerciseExpanded(exIdx),
                                            child: Text(exercise.exerciseName,
                                                style: AppTypography.h3),
                                          ),
                                        ),
                                        if (allDone)
                                          const Icon(Icons.check_circle,
                                              color: AppColors.success, size: 20),
                                      ],
                                    ),
                                    if (exercise.isExpanded) ...[
                                      const SizedBox(height: 12),
                                      // Column headers
                                      Row(
                                        children: [
                                          SizedBox(
                                              width: 36,
                                              child: Text('Set',
                                                  style: AppTypography.caption
                                                      .copyWith(fontSize: 10))),
                                          Expanded(
                                              child: Text('Weight (lbs)',
                                                  style: AppTypography.caption
                                                      .copyWith(fontSize: 10))),
                                          Expanded(
                                              child: Text('Reps',
                                                  style: AppTypography.caption
                                                      .copyWith(fontSize: 10))),
                                          const SizedBox(width: 36),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Set rows
                                      ...List.generate(exercise.sets.length,
                                          (setIdx) {
                                        final set = exercise.sets[setIdx];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 6),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 36,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${setIdx + 1}',
                                                      style:
                                                          AppTypography.body.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                        color: set.isCompleted
                                                            ? AppColors.success
                                                            : set.isPR
                                                                ? AppColors.warning
                                                                : AppColors.text1,
                                                      ),
                                                    ),
                                                    if (set.isPR)
                                                      const Text(' \ud83c\udfc6',
                                                          style: TextStyle(fontSize: 10)),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: set.isCompleted
                                                    ? Text(
                                                        set.weight?.toStringAsFixed(0) ?? '--',
                                                        style: AppTypography.body
                                                            .copyWith(
                                                                color: AppColors
                                                                    .text2))
                                                    : _MiniInput(
                                                        value: set.weight?.toStringAsFixed(0) ?? '',
                                                        hint: '0',
                                                        onChanged: (v) {
                                                          final w = double.tryParse(v);
                                                          notifier.updateSetWeight(exIdx, setIdx, w);
                                                        },
                                                      ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: set.isCompleted
                                                    ? Text(
                                                        set.reps?.toString() ?? '--',
                                                        style: AppTypography.body
                                                            .copyWith(
                                                                color: AppColors
                                                                    .text2))
                                                    : _MiniInput(
                                                        value: set.reps?.toString() ?? '',
                                                        hint: '0',
                                                        onChanged: (v) {
                                                          final r = int.tryParse(v);
                                                          notifier.updateSetReps(exIdx, setIdx, r);
                                                        },
                                                      ),
                                              ),
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                onTap: set.isCompleted
                                                    ? null
                                                    : () => notifier.completeSet(exIdx, setIdx),
                                                child: Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: set.isCompleted
                                                        ? AppColors.success
                                                        : Colors.transparent,
                                                    border: Border.all(
                                                      color: set.isCompleted
                                                          ? AppColors.success
                                                          : AppColors.text3,
                                                    ),
                                                  ),
                                                  child: set.isCompleted
                                                      ? const Icon(Icons.check,
                                                          color: Colors.white,
                                                          size: 16)
                                                      : null,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 4),
                                      Center(
                                        child: TextButton.icon(
                                          onPressed: () => notifier.addSet(exIdx),
                                          icon: const Icon(Icons.add, size: 16),
                                          label: Text('Add Set',
                                              style: AppTypography.caption
                                                  .copyWith(color: AppColors.accent)),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Bottom bar
                Container(
                  padding: EdgeInsets.fromLTRB(
                      AppDimensions.padding2XL,
                      AppDimensions.paddingMD,
                      AppDimensions.padding2XL,
                      MediaQuery.paddingOf(context).bottom + 12),
                  decoration: const BoxDecoration(
                    color: AppColors.bgSecondary,
                    border: Border(
                      top: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => notifier.startRestTimer(90),
                          icon: const Icon(Icons.timer_outlined, size: 18),
                          label: const Text('Rest Timer'),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showAddExerciseSheet,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Exercise'),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Rest timer overlay
          if (state.restTimer.isRunning)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => notifier.skipRestTimer(),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Rest Timer',
                            style: AppTypography.h2.copyWith(color: Colors.white)),
                        const SizedBox(height: 16),
                        Text(
                          '${state.restTimer.remainingSeconds}',
                          style: AppTypography.display.copyWith(
                            color: AppColors.accent,
                            fontSize: 72,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('seconds remaining',
                            style: AppTypography.caption.copyWith(color: Colors.white70)),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: () => notifier.skipRestTimer(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.accent),
                          ),
                          child: Text('Skip',
                              style: AppTypography.button
                                  .copyWith(color: AppColors.accent)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniInput extends StatelessWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;

  const _MiniInput({
    required this.value,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextField(
        controller: TextEditingController(text: value),
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: AppTypography.body.copyWith(fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          filled: true,
          fillColor: AppColors.bgTertiary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _ExercisePickerSheet extends StatefulWidget {
  final Function(dynamic) onSelect;
  final WidgetRef ref;

  const _ExercisePickerSheet({required this.onSelect, required this.ref});

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final allExercises = widget.ref.watch(allExercisesProvider);
    final filtered = _query.isEmpty
        ? allExercises
        : allExercises
            .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.text3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: AppColors.bgTertiary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final ex = filtered[index];
                return ListTile(
                  title: Text(ex.name, style: AppTypography.body),
                  subtitle: Text(ex.primaryMuscles.join(', '),
                      style: AppTypography.caption),
                  onTap: () => widget.onSelect(ex),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
