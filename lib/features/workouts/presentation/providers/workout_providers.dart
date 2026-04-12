import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/workout_repository.dart';
import '../../data/template_repository.dart';
import '../../domain/workout_model.dart';
import '../../domain/workout_template_model.dart';

// All completed workouts sorted by date
final workoutHistoryProvider = Provider<List<WorkoutModel>>((ref) {
  return ref.watch(workoutRepositoryProvider).getWorkouts('user_1');
});

// Workouts for a specific month (for calendar)
final workoutsForMonthProvider = Provider.family<List<WorkoutModel>, DateTime>((ref, month) {
  return ref.watch(workoutRepositoryProvider).getWorkoutsForMonth(month.year, month.month);
});

// Workout dates for calendar highlighting
final workoutDatesForMonthProvider = Provider.family<Set<DateTime>, DateTime>((ref, month) {
  final dates = ref.watch(workoutRepositoryProvider).getWorkoutDatesForMonth(month.year, month.month);
  return dates.toSet();
});

// Single workout by ID
final workoutByIdProvider = Provider.family<WorkoutModel?, String>((ref, id) {
  return ref.watch(workoutRepositoryProvider).getWorkoutById(id);
});

// User templates
final userTemplatesProvider = Provider<List<WorkoutTemplateModel>>((ref) {
  return ref.watch(templateRepositoryProvider).getTemplates('user_1');
});

// System templates
final systemTemplatesProvider = Provider<List<WorkoutTemplateModel>>((ref) {
  return ref.watch(templateRepositoryProvider).getSystemTemplates();
});

// All templates combined
final allTemplatesProvider = Provider<List<WorkoutTemplateModel>>((ref) {
  return [...ref.watch(userTemplatesProvider), ...ref.watch(systemTemplatesProvider)];
});

// Selected template for detail view
final selectedTemplateProvider = StateProvider<WorkoutTemplateModel?>((ref) => null);

// Total workouts count
final totalWorkoutsCountProvider = Provider<int>((ref) {
  return ref.watch(workoutHistoryProvider).length;
});

// This week's stats
final thisWeekStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final repo = ref.watch(workoutRepositoryProvider);
  final now = DateTime.now();
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final workouts = repo.getWorkoutsForDateRange(weekStart, now);

  int prs = 0;
  for (final w in workouts) {
    prs += w.personalRecords.length;
  }

  return {
    'workouts': workouts.length,
    'volume': workouts.fold<double>(0, (s, w) => s + w.totalVolume),
    'prs': prs,
    'duration': workouts.fold<int>(0, (s, w) => s + w.durationMinutes),
  };
});

// Last workout
final lastWorkoutProvider = Provider<WorkoutModel?>((ref) {
  final history = ref.watch(workoutHistoryProvider);
  return history.isNotEmpty ? history.first : null;
});
