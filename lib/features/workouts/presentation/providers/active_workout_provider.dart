import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/active_workout_state.dart';
import '../../domain/workout_model.dart';
import '../../domain/workout_template_model.dart';
import '../../data/workout_repository.dart';
import '../../../exercises/domain/exercise_model.dart';
import '../../../progress/data/progress_repository.dart';
import '../../../gamification/data/gamification_repository.dart';
import '../../../gamification/domain/badge_model.dart';

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  final WorkoutRepository _workoutRepo;
  final ProgressRepository _progressRepo;
  final GamificationRepository _gamificationRepo;
  Timer? _timer;
  Timer? _restTimer;

  ActiveWorkoutNotifier(this._workoutRepo, this._progressRepo, this._gamificationRepo)
      : super(ActiveWorkoutState.empty());

  bool get isActive => state.isActive;
  bool get hasRestTimer => state.restTimer.isRunning;

  // --- Start Workout ---

  void startFromTemplate(WorkoutTemplateModel template) {
    final exercises = template.exercises.map((te) => ActiveExercise(
      exerciseId: te.exerciseId,
      exerciseName: te.exerciseName,
      sets: List.generate(te.targetSets, (i) => ActiveSet(
        setNumber: i + 1,
        weight: te.targetWeight,
      )),
      isExpanded: false,
    )).toList();

    if (exercises.isNotEmpty) {
      exercises[0] = exercises[0].copyWith(isExpanded: true);
    }

    state = ActiveWorkoutState(
      templateId: template.id,
      templateName: template.name,
      name: template.name,
      startedAt: DateTime.now(),
      exercises: exercises,
      isActive: true,
      isPaused: false,
      elapsedSeconds: 0,
      currentExerciseIndex: 0,
    );

    _startWorkoutTimer();
  }

  void startEmpty(String name) {
    state = ActiveWorkoutState(
      name: name.isEmpty ? 'Quick Workout' : name,
      startedAt: DateTime.now(),
      exercises: const [],
      isActive: true,
      isPaused: false,
      elapsedSeconds: 0,
      currentExerciseIndex: 0,
    );
    _startWorkoutTimer();
  }

  // --- Exercise Management ---

  void addExercise(ExerciseModel exercise) {
    final newExercise = ActiveExercise(
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      sets: const [ActiveSet(setNumber: 1)],
      isExpanded: true,
    );
    final exercises = [...state.exercises, newExercise];
    state = state.copyWith(exercises: exercises);
  }

  void removeExercise(int index) {
    if (index < 0 || index >= state.exercises.length) return;
    final exercises = List<ActiveExercise>.from(state.exercises)..removeAt(index);
    state = state.copyWith(exercises: exercises);
  }

  void reorderExercise(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.exercises.length) return;
    if (newIndex < 0 || newIndex >= state.exercises.length) return;
    final exercises = List<ActiveExercise>.from(state.exercises);
    final item = exercises.removeAt(oldIndex);
    exercises.insert(newIndex, item);
    state = state.copyWith(exercises: exercises);
  }

  void toggleExerciseExpanded(int index) {
    if (index < 0 || index >= state.exercises.length) return;
    final exercises = List<ActiveExercise>.from(state.exercises);
    exercises[index] = exercises[index].copyWith(
      isExpanded: !exercises[index].isExpanded,
    );
    state = state.copyWith(exercises: exercises);
  }

  // --- Set Management ---

  void addSet(int exerciseIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= state.exercises.length) return;
    final exercises = List<ActiveExercise>.from(state.exercises);
    final exercise = exercises[exerciseIndex];
    final lastSet = exercise.sets.isNotEmpty ? exercise.sets.last : null;
    final newSet = ActiveSet(
      setNumber: exercise.sets.length + 1,
      weight: lastSet?.weight,
    );
    exercises[exerciseIndex] = exercise.copyWith(
      sets: [...exercise.sets, newSet],
    );
    state = state.copyWith(exercises: exercises);
  }

  void removeSet(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= state.exercises.length) return;
    final exercises = List<ActiveExercise>.from(state.exercises);
    final sets = List<ActiveSet>.from(exercises[exerciseIndex].sets);
    if (setIndex < 0 || setIndex >= sets.length) return;
    sets.removeAt(setIndex);
    // Renumber
    for (int i = 0; i < sets.length; i++) {
      sets[i] = sets[i].copyWith(setNumber: i + 1);
    }
    exercises[exerciseIndex] = exercises[exerciseIndex].copyWith(sets: sets);
    state = state.copyWith(exercises: exercises);
  }

  void updateSetWeight(int exerciseIndex, int setIndex, double? weight) {
    _updateSet(exerciseIndex, setIndex, (s) => s.copyWith(weight: weight));
  }

  void updateSetReps(int exerciseIndex, int setIndex, int? reps) {
    _updateSet(exerciseIndex, setIndex, (s) => s.copyWith(reps: reps));
  }

  void updateSetRPE(int exerciseIndex, int setIndex, int? rpe) {
    _updateSet(exerciseIndex, setIndex, (s) => s.copyWith(rpe: rpe?.toDouble()));
  }

  void toggleSetWarmup(int exerciseIndex, int setIndex) {
    _updateSet(exerciseIndex, setIndex, (s) => s.copyWith(isWarmup: !s.isWarmup));
  }

  void toggleSetDropset(int exerciseIndex, int setIndex) {
    _updateSet(exerciseIndex, setIndex, (s) => s.copyWith(isDropset: !s.isDropset));
  }

  void toggleSetFailure(int exerciseIndex, int setIndex) {
    _updateSet(exerciseIndex, setIndex, (s) => s.copyWith(isFailure: !s.isFailure));
  }

  void _updateSet(int exerciseIndex, int setIndex, ActiveSet Function(ActiveSet) updater) {
    if (exerciseIndex < 0 || exerciseIndex >= state.exercises.length) return;
    final exercises = List<ActiveExercise>.from(state.exercises);
    final sets = List<ActiveSet>.from(exercises[exerciseIndex].sets);
    if (setIndex < 0 || setIndex >= sets.length) return;
    sets[setIndex] = updater(sets[setIndex]);
    exercises[exerciseIndex] = exercises[exerciseIndex].copyWith(sets: sets);
    state = state.copyWith(exercises: exercises);
  }

  // --- Complete a Set ---

  void completeSet(int exerciseIndex, int setIndex) {
    if (exerciseIndex < 0 || exerciseIndex >= state.exercises.length) return;
    final exercises = List<ActiveExercise>.from(state.exercises);
    final exercise = exercises[exerciseIndex];
    final sets = List<ActiveSet>.from(exercise.sets);
    if (setIndex < 0 || setIndex >= sets.length) return;

    final set = sets[setIndex];
    if (set.weight == null || set.reps == null || set.weight! <= 0 || set.reps! <= 0) return;

    // Check for PR
    bool isPR = false;
    if (!set.isWarmup) {
      final currentRecord = _progressRepo.getPersonalRecordForExercise('user_1', exercise.exerciseId);
      if (currentRecord != null) {
        final est1RM = ProgressRepository.calculate1RM(set.weight!, set.reps!);
        if (currentRecord.estimated1rm == null || est1RM > currentRecord.estimated1rm!.value) {
          isPR = true;
        }
      } else {
        isPR = true; // First time = always a PR
      }
    }

    sets[setIndex] = set.copyWith(
      isCompleted: true,
      isPR: isPR,
    );

    // Check if all sets in this exercise are completed
    final allDone = sets.every((s) => s.isCompleted);
    exercises[exerciseIndex] = exercise.copyWith(
      sets: sets,
      isCompleted: allDone,
    );

    // Auto-expand next exercise if this one is done
    if (allDone && exerciseIndex + 1 < exercises.length) {
      exercises[exerciseIndex] = exercises[exerciseIndex].copyWith(isExpanded: false);
      exercises[exerciseIndex + 1] = exercises[exerciseIndex + 1].copyWith(isExpanded: true);
      state = state.copyWith(
        exercises: exercises,
        currentExerciseIndex: exerciseIndex + 1,
      );
    } else {
      state = state.copyWith(exercises: exercises);
    }
  }

  // --- Rest Timer ---

  void startRestTimer(int seconds) {
    _restTimer?.cancel();
    int remaining = seconds;
    state = state.copyWith(
      restTimer: RestTimerState(totalSeconds: seconds, remainingSeconds: remaining, isRunning: true),
    );
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      if (remaining <= 0) {
        timer.cancel();
        state = state.copyWith(
          restTimer: state.restTimer.copyWith(remainingSeconds: 0, isRunning: false),
        );
      } else {
        state = state.copyWith(
          restTimer: state.restTimer.copyWith(remainingSeconds: remaining),
        );
      }
    });
  }

  void skipRestTimer() {
    _restTimer?.cancel();
    state = state.copyWith(
      restTimer: state.restTimer.copyWith(remainingSeconds: 0, isRunning: false),
    );
  }

  // --- Workout Timer ---

  void _startWorkoutTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isPaused) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  String get formattedTime {
    final h = state.elapsedSeconds ~/ 3600;
    final m = (state.elapsedSeconds % 3600) ~/ 60;
    final s = state.elapsedSeconds % 60;
    if (h > 0) return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // --- Computed Stats ---

  int get completedExerciseCount => state.exercises.where((e) => e.isCompleted).length;
  int get totalExerciseCount => state.exercises.length;

  double get totalVolume {
    double vol = 0;
    for (final ex in state.exercises) {
      for (final set in ex.sets) {
        if (set.isCompleted && !set.isWarmup && set.weight != null && set.reps != null) {
          vol += set.weight! * set.reps!;
        }
      }
    }
    return vol;
  }

  int get totalCompletedSets {
    return state.exercises.fold(0, (sum, ex) => sum + ex.sets.where((s) => s.isCompleted).length);
  }

  int get totalCompletedReps {
    return state.exercises.fold(0, (sum, ex) =>
        sum + ex.sets.where((s) => s.isCompleted && s.reps != null).fold(0, (s, set) => s + set.reps!));
  }

  List<PersonalRecordEntry> get personalRecordsHit {
    final prs = <PersonalRecordEntry>[];
    for (final ex in state.exercises) {
      for (final set in ex.sets) {
        if (set.isPR && set.weight != null && set.reps != null) {
          prs.add(PersonalRecordEntry(
            exerciseId: ex.exerciseId,
            exerciseName: ex.exerciseName,
            type: 'estimated1rm',
            value: ProgressRepository.calculate1RM(set.weight!, set.reps!),
          ));
        }
      }
    }
    return prs;
  }

  // --- Finish Workout ---

  Future<WorkoutModel> finishWorkout() async {
    _timer?.cancel();
    _restTimer?.cancel();

    final now = DateTime.now();
    final prs = personalRecordsHit;

    // Build workout exercises
    final workoutExercises = state.exercises.map((ex) {
      return WorkoutExercise(
        exerciseId: ex.exerciseId,
        exerciseName: ex.exerciseName,
        order: state.exercises.indexOf(ex),
        sets: ex.sets.where((s) => s.isCompleted).map((s) => WorkoutSet(
          setNumber: s.setNumber,
          weight: s.weight ?? 0,
          reps: s.reps ?? 0,
          rpe: s.rpe,
          isWarmup: s.isWarmup,
          isDropset: s.isDropset,
          isFailure: s.isFailure,
          isPR: s.isPR,
          completedAt: now,
        )).toList(),
      );
    }).toList();

    final workout = WorkoutModel(
      id: 'workout_${now.millisecondsSinceEpoch}',
      userId: 'user_1',
      templateId: state.templateId,
      templateName: state.templateName,
      name: state.name,
      startedAt: state.startedAt,
      finishedAt: now,
      durationMinutes: state.elapsedSeconds ~/ 60,
      totalVolume: totalVolume,
      totalSets: totalCompletedSets,
      totalReps: totalCompletedReps,
      exercises: workoutExercises,
      personalRecords: prs,
      isPublic: false,
    );

    // Save workout
    _workoutRepo.saveWorkout(workout);

    // Update personal records
    for (final ex in workoutExercises) {
      double maxWeight = 0;
      int maxReps = 0;
      double exVolume = 0;
      for (final set in ex.sets) {
        if (!set.isWarmup) {
          if (set.weight > maxWeight) maxWeight = set.weight;
          if (set.reps > maxReps) maxReps = set.reps;
          exVolume += set.weight * set.reps;
        }
      }
      if (maxWeight > 0) {
        _progressRepo.updatePersonalRecord(
          userId: 'user_1',
          exerciseId: ex.exerciseId,
          exerciseName: ex.exerciseName,
          weight: maxWeight,
          reps: maxReps,
          volume: exVolume,
          workoutId: workout.id,
        );
      }
    }

    // Award XP
    _gamificationRepo.awardXP(XpConstants.workoutComplete, 'Workout completed');
    for (final _ in prs) {
      _gamificationRepo.awardXP(XpConstants.personalRecord, 'Personal Record');
    }
    _gamificationRepo.awardXP(XpConstants.streakDay, 'Streak day');

    // Reset state
    state = ActiveWorkoutState.empty();

    return workout;
  }

  void discardWorkout() {
    _timer?.cancel();
    _restTimer?.cancel();
    state = ActiveWorkoutState.empty();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
}

final activeWorkoutProvider = StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>((ref) {
  return ActiveWorkoutNotifier(
    ref.watch(workoutRepositoryProvider),
    ref.watch(progressRepositoryProvider),
    ref.watch(gamificationRepositoryProvider),
  );
});

// Convenience providers
final isWorkoutActiveProvider = Provider<bool>((ref) {
  return ref.watch(activeWorkoutProvider).isActive;
});

final workoutElapsedProvider = Provider<int>((ref) {
  return ref.watch(activeWorkoutProvider).elapsedSeconds;
});
