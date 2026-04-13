import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/workout_model.dart';

/// In-memory workout storage. Will be replaced by Firestore.
class WorkoutRepository {
  final List<WorkoutModel> _workouts = [];
  int _idCounter = 1;

  WorkoutRepository() {
    _workouts.addAll(_generateMockWorkouts());
  }

  /// Saves a completed workout and returns its assigned ID.
  String saveWorkout(WorkoutModel workout) {
    final id = 'workout_${_idCounter++}';
    final saved = workout.copyWith(id: id);
    _workouts.add(saved);
    return id;
  }

  /// Returns all workouts for a user, sorted by date descending.
  List<WorkoutModel> getWorkouts(String userId) {
    final results = _workouts.where((w) => w.userId == userId).toList();
    results.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return results;
  }

  /// Returns a single workout by ID.
  WorkoutModel? getWorkoutById(String id) {
    try {
      return _workouts.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns workouts within a date range (inclusive).
  List<WorkoutModel> getWorkoutsForDateRange(DateTime start, DateTime end) {
    return _workouts.where((w) {
      return !w.startedAt.isBefore(start) && !w.startedAt.isAfter(end);
    }).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  /// Returns workouts for a specific month.
  List<WorkoutModel> getWorkoutsForMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    return getWorkoutsForDateRange(start, end);
  }

  /// Returns just the dates that have workouts in a given month (for calendar dots).
  List<DateTime> getWorkoutDatesForMonth(int year, int month) {
    return getWorkoutsForMonth(year, month)
        .map((w) => DateTime(w.startedAt.year, w.startedAt.month, w.startedAt.day))
        .toSet()
        .toList()
      ..sort();
  }

  /// Deletes a workout by ID. Returns true if found and deleted.
  bool deleteWorkout(String id) {
    final index = _workouts.indexWhere((w) => w.id == id);
    if (index == -1) return false;
    _workouts.removeAt(index);
    return true;
  }

  /// Calculates total volume across all user workouts, optionally within a date range.
  double getTotalVolume(String userId, {DateTime? start, DateTime? end}) {
    var workouts = _workouts.where((w) => w.userId == userId);
    if (start != null) {
      workouts = workouts.where((w) => !w.startedAt.isBefore(start));
    }
    if (end != null) {
      workouts = workouts.where((w) => !w.startedAt.isAfter(end));
    }
    return workouts.fold(0.0, (sum, w) => sum + w.totalVolume);
  }

  /// Returns workout count, optionally within a date range.
  int getWorkoutCount(String userId, {DateTime? start, DateTime? end}) {
    var workouts = _workouts.where((w) => w.userId == userId);
    if (start != null) {
      workouts = workouts.where((w) => !w.startedAt.isBefore(start));
    }
    if (end != null) {
      workouts = workouts.where((w) => !w.startedAt.isAfter(end));
    }
    return workouts.length;
  }

  // ---------------------------------------------------------------------------
  // Mock data: 15 realistic workouts over the last 30 days
  // ---------------------------------------------------------------------------
  List<WorkoutModel> _generateMockWorkouts() {
    final now = DateTime.now();
    final rng = Random(42);
    const userId = 'user_${1337}'; // matches demo user hash placeholder
    final mockUserId = 'user_${('demo@gymgenius.com').hashCode.abs()}';

    // Exercise pools for different workout types
    List<WorkoutModel> workouts = [];
    int id = 100;

    // Helper to create a mock workout
    WorkoutModel makeWorkout({
      required String name,
      required int daysAgo,
      required List<WorkoutExercise> exercises,
      int durationMin = 55,
      String? templateId,
      String? templateName,
    }) {
      final startTime =
          now.subtract(Duration(days: daysAgo, hours: rng.nextInt(3) + 6));
      final endTime = startTime.add(Duration(minutes: durationMin));

      double totalVol = 0;
      int totalSets = 0;
      int totalReps = 0;
      List<PersonalRecordEntry> prs = [];

      for (final ex in exercises) {
        for (final s in ex.sets) {
          if (!s.isWarmup) {
            totalVol += s.weight * s.reps;
            totalSets++;
            totalReps += s.reps;
          }
        }
      }

      return WorkoutModel(
        id: 'mock_workout_${id++}',
        userId: mockUserId,
        templateId: templateId,
        templateName: templateName,
        name: name,
        startedAt: startTime,
        finishedAt: endTime,
        durationMinutes: durationMin,
        totalVolume: totalVol,
        totalSets: totalSets,
        totalReps: totalReps,
        exercises: exercises,
        personalRecords: prs,
        mood: rng.nextInt(3) + 3,
      );
    }

    WorkoutSet makeSet(int num, double weight, int reps, {bool warmup = false, bool pr = false}) {
      return WorkoutSet(
        setNumber: num,
        weight: weight,
        reps: reps,
        isWarmup: warmup,
        isPR: pr,
        completedAt: now.subtract(Duration(days: rng.nextInt(30))),
      );
    }

    // Push Day workouts
    final pushExercises = [
      WorkoutExercise(
        exerciseId: 'ex_barbell_bench_press',
        exerciseName: 'Barbell Bench Press',
        order: 0,
        sets: [
          makeSet(1, 60, 10, warmup: true),
          makeSet(2, 80, 8),
          makeSet(3, 85, 6),
          makeSet(4, 85, 6),
          makeSet(5, 80, 8),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_overhead_press',
        exerciseName: 'Overhead Press',
        order: 1,
        sets: [
          makeSet(1, 40, 10),
          makeSet(2, 50, 8),
          makeSet(3, 50, 7),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_cable_flyes',
        exerciseName: 'Cable Flyes',
        order: 2,
        sets: [
          makeSet(1, 15, 12),
          makeSet(2, 17.5, 10),
          makeSet(3, 17.5, 10),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_tricep_pushdown',
        exerciseName: 'Tricep Cable Pushdown',
        order: 3,
        sets: [
          makeSet(1, 25, 12),
          makeSet(2, 30, 10),
          makeSet(3, 30, 10),
        ],
      ),
    ];

    // Pull Day workouts
    final pullExercises = [
      WorkoutExercise(
        exerciseId: 'ex_barbell_row',
        exerciseName: 'Barbell Bent-Over Row',
        order: 0,
        sets: [
          makeSet(1, 60, 10, warmup: true),
          makeSet(2, 70, 8),
          makeSet(3, 75, 6),
          makeSet(4, 70, 8),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_pull_ups',
        exerciseName: 'Pull-Ups',
        order: 1,
        sets: [
          makeSet(1, 0, 10),
          makeSet(2, 0, 8),
          makeSet(3, 0, 7),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_seated_cable_row',
        exerciseName: 'Seated Cable Row',
        order: 2,
        sets: [
          makeSet(1, 50, 10),
          makeSet(2, 55, 8),
          makeSet(3, 55, 8),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_barbell_curl',
        exerciseName: 'Barbell Curl',
        order: 3,
        sets: [
          makeSet(1, 25, 12),
          makeSet(2, 30, 10),
          makeSet(3, 30, 8),
        ],
      ),
    ];

    // Leg Day workouts
    final legExercises = [
      WorkoutExercise(
        exerciseId: 'ex_barbell_squat',
        exerciseName: 'Barbell Back Squat',
        order: 0,
        sets: [
          makeSet(1, 60, 10, warmup: true),
          makeSet(2, 100, 8),
          makeSet(3, 110, 6),
          makeSet(4, 110, 5),
          makeSet(5, 100, 8),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_romanian_deadlift',
        exerciseName: 'Romanian Deadlift',
        order: 1,
        sets: [
          makeSet(1, 70, 10),
          makeSet(2, 80, 8),
          makeSet(3, 80, 8),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_leg_press',
        exerciseName: 'Leg Press',
        order: 2,
        sets: [
          makeSet(1, 140, 12),
          makeSet(2, 160, 10),
          makeSet(3, 160, 10),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_standing_calf_raise',
        exerciseName: 'Standing Calf Raise',
        order: 3,
        sets: [
          makeSet(1, 60, 15),
          makeSet(2, 70, 12),
          makeSet(3, 70, 12),
        ],
      ),
    ];

    // Upper body
    final upperExercises = [
      WorkoutExercise(
        exerciseId: 'ex_incline_bench_press',
        exerciseName: 'Incline Barbell Bench Press',
        order: 0,
        sets: [
          makeSet(1, 50, 10, warmup: true),
          makeSet(2, 65, 8),
          makeSet(3, 70, 6),
          makeSet(4, 65, 8),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_lat_pulldown',
        exerciseName: 'Lat Pulldown',
        order: 1,
        sets: [
          makeSet(1, 50, 10),
          makeSet(2, 60, 8),
          makeSet(3, 60, 8),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_lateral_raise',
        exerciseName: 'Dumbbell Lateral Raise',
        order: 2,
        sets: [
          makeSet(1, 10, 15),
          makeSet(2, 12, 12),
          makeSet(3, 12, 12),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_hammer_curl',
        exerciseName: 'Hammer Curl',
        order: 3,
        sets: [
          makeSet(1, 14, 12),
          makeSet(2, 16, 10),
          makeSet(3, 16, 10),
        ],
      ),
    ];

    // Full body
    final fullBodyExercises = [
      WorkoutExercise(
        exerciseId: 'ex_deadlift',
        exerciseName: 'Conventional Deadlift',
        order: 0,
        sets: [
          makeSet(1, 80, 8, warmup: true),
          makeSet(2, 120, 5),
          makeSet(3, 130, 3),
          makeSet(4, 120, 5),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_dumbbell_bench_press',
        exerciseName: 'Dumbbell Bench Press',
        order: 1,
        sets: [
          makeSet(1, 30, 10),
          makeSet(2, 34, 8),
          makeSet(3, 34, 8),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_dumbbell_lunge',
        exerciseName: 'Dumbbell Walking Lunge',
        order: 2,
        sets: [
          makeSet(1, 20, 12),
          makeSet(2, 22, 10),
          makeSet(3, 22, 10),
        ],
      ),
      WorkoutExercise(
        exerciseId: 'ex_plank',
        exerciseName: 'Plank',
        order: 3,
        sets: [
          makeSet(1, 0, 60), // reps = seconds for plank
          makeSet(2, 0, 45),
          makeSet(3, 0, 45),
        ],
      ),
    ];

    // Generate 15 workouts spanning 30 days
    // Pattern: Push, Pull, Legs, rest, Upper, Full Body, rest, repeat
    final schedule = [
      (name: 'Push Day', exercises: pushExercises, duration: 58, days: 1),
      (name: 'Pull Day', exercises: pullExercises, duration: 52, days: 2),
      (name: 'Leg Day', exercises: legExercises, duration: 65, days: 4),
      (name: 'Upper Body', exercises: upperExercises, duration: 50, days: 6),
      (name: 'Full Body', exercises: fullBodyExercises, duration: 55, days: 7),
      (name: 'Push Day', exercises: pushExercises, duration: 55, days: 9),
      (name: 'Pull Day', exercises: pullExercises, duration: 48, days: 10),
      (name: 'Leg Day', exercises: legExercises, duration: 62, days: 12),
      (name: 'Upper Body', exercises: upperExercises, duration: 53, days: 14),
      (name: 'Full Body', exercises: fullBodyExercises, duration: 57, days: 16),
      (name: 'Push Day', exercises: pushExercises, duration: 60, days: 18),
      (name: 'Pull Day', exercises: pullExercises, duration: 50, days: 20),
      (name: 'Leg Day', exercises: legExercises, duration: 63, days: 22),
      (name: 'Upper Body', exercises: upperExercises, duration: 51, days: 25),
      (name: 'Push Day', exercises: pushExercises, duration: 56, days: 28),
    ];

    for (final entry in schedule) {
      workouts.add(makeWorkout(
        name: entry.name,
        daysAgo: entry.days,
        exercises: entry.exercises,
        durationMin: entry.duration,
      ));
    }

    return workouts;
  }
}

final workoutRepositoryProvider =
    Provider<WorkoutRepository>((ref) => WorkoutRepository());
