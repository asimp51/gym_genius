import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/personal_record_model.dart';
import '../domain/body_measurement_model.dart';
import '../../workouts/data/workout_repository.dart';

class ProgressRepository {
  final WorkoutRepository _workoutRepo;
  final List<BodyMeasurementModel> _measurements = [];
  final Map<String, PersonalRecordModel> _personalRecords = {};

  ProgressRepository(this._workoutRepo) {
    _seedMockData();
  }

  // --- Personal Records ---

  List<PersonalRecordModel> getPersonalRecords(String userId) {
    return _personalRecords.values.toList();
  }

  PersonalRecordModel? getPersonalRecordForExercise(String userId, String exerciseId) {
    return _personalRecords[exerciseId];
  }

  bool updatePersonalRecord({
    required String userId,
    required String exerciseId,
    required String exerciseName,
    required double weight,
    required int reps,
    required double volume,
    required String workoutId,
  }) {
    final estimated1rm = calculate1RM(weight, reps);
    final now = DateTime.now();
    bool newPR = false;

    final existing = _personalRecords[exerciseId];

    if (existing == null) {
      _personalRecords[exerciseId] = PersonalRecordModel(
        exerciseId: exerciseId,
        exerciseName: exerciseName,
        maxWeight: RecordEntry(value: weight, date: now, workoutId: workoutId),
        maxReps: RepRecordEntry(value: reps, weight: weight, date: now, workoutId: workoutId),
        maxVolume: RecordEntry(value: volume, date: now, workoutId: workoutId),
        estimated1rm: RecordEntry(value: estimated1rm, date: now, workoutId: workoutId),
      );
      newPR = true;
    } else {
      PersonalRecordModel updated = existing;

      if (existing.maxWeight == null || weight > existing.maxWeight!.value) {
        updated = updated.copyWith(
          maxWeight: RecordEntry(value: weight, date: now, workoutId: workoutId),
        );
        newPR = true;
      }
      if (existing.maxReps == null || reps > existing.maxReps!.value) {
        updated = updated.copyWith(
          maxReps: RepRecordEntry(value: reps, weight: weight, date: now, workoutId: workoutId),
        );
        newPR = true;
      }
      if (existing.maxVolume == null || volume > existing.maxVolume!.value) {
        updated = updated.copyWith(
          maxVolume: RecordEntry(value: volume, date: now, workoutId: workoutId),
        );
        newPR = true;
      }
      if (existing.estimated1rm == null || estimated1rm > existing.estimated1rm!.value) {
        updated = updated.copyWith(
          estimated1rm: RecordEntry(value: estimated1rm, date: now, workoutId: workoutId),
        );
        newPR = true;
      }

      _personalRecords[exerciseId] = updated;
    }

    return newPR;
  }

  // --- Body Measurements ---

  List<BodyMeasurementModel> getBodyMeasurements(String userId) {
    return List.from(_measurements)..sort((a, b) => b.date.compareTo(a.date));
  }

  void addBodyMeasurement(BodyMeasurementModel measurement) {
    _measurements.add(measurement);
  }

  // --- Analytics ---

  List<double> getWeeklyVolume(String userId, int weeks) {
    final now = DateTime.now();
    final volumes = <double>[];

    for (int i = weeks - 1; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: 7 * i + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final workouts = _workoutRepo.getWorkoutsForDateRange(weekStart, weekEnd);
      final vol = workouts.fold<double>(0, (sum, w) => sum + w.totalVolume);
      volumes.add(vol);
    }

    return volumes;
  }

  List<int> getWorkoutFrequency(String userId, int weeks) {
    final now = DateTime.now();
    final freq = <int>[];

    for (int i = weeks - 1; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: 7 * i + now.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final count = _workoutRepo.getWorkoutsForDateRange(weekStart, weekEnd).length;
      freq.add(count);
    }

    return freq;
  }

  List<MapEntry<DateTime, double>> getExercise1RMHistory(String userId, String exerciseId) {
    final workouts = _workoutRepo.getWorkouts(userId);
    final history = <MapEntry<DateTime, double>>[];

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        if (exercise.exerciseId == exerciseId) {
          double best1RM = 0;
          for (final set in exercise.sets) {
            if (set.isCompleted && !set.isWarmup) {
              final est = calculate1RM(set.weight, set.reps);
              if (est > best1RM) best1RM = est;
            }
          }
          if (best1RM > 0) {
            history.add(MapEntry(workout.startedAt, best1RM));
          }
        }
      }
    }

    history.sort((a, b) => a.key.compareTo(b.key));
    return history;
  }

  List<MapEntry<DateTime, double>> getBodyWeightTrend(String userId) {
    return _measurements
        .where((m) => m.weight != null)
        .map((m) => MapEntry(m.date, m.weight!))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));
  }

  Map<String, double> getMuscleDistribution(String userId) {
    final workouts = _workoutRepo.getWorkouts(userId);
    final distribution = <String, double>{};

    for (final workout in workouts) {
      for (final exercise in workout.exercises) {
        final volume = exercise.sets
            .where((s) => s.isCompleted && !s.isWarmup)
            .fold<double>(0, (sum, s) => sum + s.weight * s.reps);

        final key = exercise.exerciseName;
        distribution[key] = (distribution[key] ?? 0) + volume;
      }
    }

    return distribution;
  }

  Map<String, dynamic> getMonthlyStats(String userId) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final workouts = _workoutRepo.getWorkoutsForDateRange(monthStart, now);

    int prCount = 0;
    for (final w in workouts) {
      prCount += w.personalRecords.length;
    }

    return {
      'workouts': workouts.length,
      'volume': workouts.fold<double>(0, (s, w) => s + w.totalVolume),
      'prs': prCount,
      'duration': workouts.fold<int>(0, (s, w) => s + w.durationMinutes),
    };
  }

  // --- Helpers ---

  static double calculate1RM(double weight, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30.0);
  }

  void _seedMockData() {
    final now = DateTime.now();

    // Body measurements over 8 weeks
    final weights = [82.5, 82.1, 81.6, 81.3, 80.9, 80.7, 80.4, 80.2];
    for (int i = 0; i < weights.length; i++) {
      _measurements.add(BodyMeasurementModel(
        id: 'bm_$i',
        date: now.subtract(Duration(days: (7 - i) * 7)),
        weight: weights[i],
        bodyFat: 18.0 - (i * 0.4),
        chest: 99.0 + (i * 0.4),
        waist: 85.0 - (i * 0.4),
        leftArm: 36.0 + (i * 0.25),
        rightArm: 36.5 + (i * 0.25),
        leftThigh: 55.0 + (i * 0.4),
        rightThigh: 55.5 + (i * 0.4),
      ));
    }

    // Personal records
    _personalRecords['bench_press'] = PersonalRecordModel(
      exerciseId: 'bench_press',
      exerciseName: 'Barbell Bench Press',
      maxWeight: RecordEntry(value: 85, date: now.subtract(const Duration(days: 2)), workoutId: 'w1'),
      maxReps: RepRecordEntry(value: 10, weight: 70, date: now.subtract(const Duration(days: 14)), workoutId: 'w3'),
      maxVolume: RecordEntry(value: 2400, date: now.subtract(const Duration(days: 2)), workoutId: 'w1'),
      estimated1rm: RecordEntry(value: 105, date: now.subtract(const Duration(days: 2)), workoutId: 'w1'),
    );
    _personalRecords['squat'] = PersonalRecordModel(
      exerciseId: 'squat',
      exerciseName: 'Barbell Squat',
      maxWeight: RecordEntry(value: 120, date: now.subtract(const Duration(days: 5)), workoutId: 'w2'),
      maxReps: RepRecordEntry(value: 8, weight: 100, date: now.subtract(const Duration(days: 12)), workoutId: 'w4'),
      maxVolume: RecordEntry(value: 3600, date: now.subtract(const Duration(days: 5)), workoutId: 'w2'),
      estimated1rm: RecordEntry(value: 140, date: now.subtract(const Duration(days: 5)), workoutId: 'w2'),
    );
    _personalRecords['deadlift'] = PersonalRecordModel(
      exerciseId: 'deadlift',
      exerciseName: 'Deadlift',
      maxWeight: RecordEntry(value: 140, date: now.subtract(const Duration(days: 8)), workoutId: 'w5'),
      maxReps: RepRecordEntry(value: 6, weight: 120, date: now.subtract(const Duration(days: 15)), workoutId: 'w6'),
      maxVolume: RecordEntry(value: 2800, date: now.subtract(const Duration(days: 8)), workoutId: 'w5'),
      estimated1rm: RecordEntry(value: 162, date: now.subtract(const Duration(days: 8)), workoutId: 'w5'),
    );
    _personalRecords['ohp'] = PersonalRecordModel(
      exerciseId: 'ohp',
      exerciseName: 'Overhead Press',
      maxWeight: RecordEntry(value: 60, date: now.subtract(const Duration(days: 2)), workoutId: 'w1'),
      maxReps: RepRecordEntry(value: 10, weight: 45, date: now.subtract(const Duration(days: 14)), workoutId: 'w3'),
      maxVolume: RecordEntry(value: 1200, date: now.subtract(const Duration(days: 2)), workoutId: 'w1'),
      estimated1rm: RecordEntry(value: 70, date: now.subtract(const Duration(days: 2)), workoutId: 'w1'),
    );
    _personalRecords['barbell_row'] = PersonalRecordModel(
      exerciseId: 'barbell_row',
      exerciseName: 'Barbell Row',
      maxWeight: RecordEntry(value: 80, date: now.subtract(const Duration(days: 4)), workoutId: 'w7'),
      maxReps: RepRecordEntry(value: 10, weight: 65, date: now.subtract(const Duration(days: 11)), workoutId: 'w8'),
      maxVolume: RecordEntry(value: 2000, date: now.subtract(const Duration(days: 4)), workoutId: 'w7'),
      estimated1rm: RecordEntry(value: 95, date: now.subtract(const Duration(days: 4)), workoutId: 'w7'),
    );
    _personalRecords['leg_press'] = PersonalRecordModel(
      exerciseId: 'leg_press',
      exerciseName: 'Leg Press',
      maxWeight: RecordEntry(value: 200, date: now.subtract(const Duration(days: 5)), workoutId: 'w2'),
      maxReps: RepRecordEntry(value: 12, weight: 160, date: now.subtract(const Duration(days: 12)), workoutId: 'w4'),
      maxVolume: RecordEntry(value: 4800, date: now.subtract(const Duration(days: 5)), workoutId: 'w2'),
      estimated1rm: RecordEntry(value: 240, date: now.subtract(const Duration(days: 5)), workoutId: 'w2'),
    );
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(ref.watch(workoutRepositoryProvider));
});
