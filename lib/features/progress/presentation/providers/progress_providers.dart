import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/progress_repository.dart';
import '../../domain/personal_record_model.dart';
import '../../domain/body_measurement_model.dart';

// Weekly volume data for bar charts
final weeklyVolumeProvider = Provider<List<double>>((ref) {
  return ref.watch(progressRepositoryProvider).getWeeklyVolume('user_1', 8);
});

// Workout frequency per week
final workoutFrequencyProvider = Provider<List<int>>((ref) {
  return ref.watch(progressRepositoryProvider).getWorkoutFrequency('user_1', 4);
});

// Body weight trend
final bodyWeightTrendProvider = Provider<List<MapEntry<DateTime, double>>>((ref) {
  return ref.watch(progressRepositoryProvider).getBodyWeightTrend('user_1');
});

// Muscle volume distribution
final muscleDistributionProvider = Provider<Map<String, double>>((ref) {
  return ref.watch(progressRepositoryProvider).getMuscleDistribution('user_1');
});

// Monthly summary stats
final monthlyStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(progressRepositoryProvider).getMonthlyStats('user_1');
});

// All personal records
final personalRecordsProvider = Provider<List<PersonalRecordModel>>((ref) {
  return ref.watch(progressRepositoryProvider).getPersonalRecords('user_1');
});

// PR for specific exercise
final exercisePRProvider = Provider.family<PersonalRecordModel?, String>((ref, exerciseId) {
  return ref.watch(progressRepositoryProvider).getPersonalRecordForExercise('user_1', exerciseId);
});

// 1RM history for an exercise
final exercise1RMHistoryProvider = Provider.family<List<MapEntry<DateTime, double>>, String>((ref, exerciseId) {
  return ref.watch(progressRepositoryProvider).getExercise1RMHistory('user_1', exerciseId);
});

// Body measurements
final bodyMeasurementsProvider = Provider<List<BodyMeasurementModel>>((ref) {
  return ref.watch(progressRepositoryProvider).getBodyMeasurements('user_1');
});

// Latest body measurement
final latestMeasurementProvider = Provider<BodyMeasurementModel?>((ref) {
  final measurements = ref.watch(bodyMeasurementsProvider);
  return measurements.isNotEmpty ? measurements.first : null;
});

// Selected exercise for strength progress view
final selectedProgressExerciseProvider = StateProvider<String>((ref) => 'bench_press');
