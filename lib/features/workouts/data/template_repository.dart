import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/workout_template_model.dart';

/// In-memory template storage. Will be replaced by Firestore.
class TemplateRepository {
  final List<WorkoutTemplateModel> _templates = [];
  int _idCounter = 1;

  TemplateRepository() {
    _templates.addAll(_buildUserTemplates());
    _templates.addAll(_buildSystemTemplates());
  }

  /// Returns all user-created templates for a given user.
  List<WorkoutTemplateModel> getTemplates(String userId) {
    return _templates
        .where((t) => !t.isSystem && (t.userId == userId || t.userId == null))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Returns all built-in system templates.
  List<WorkoutTemplateModel> getSystemTemplates() {
    return _templates.where((t) => t.isSystem).toList();
  }

  /// Creates a new user template.
  WorkoutTemplateModel createTemplate(WorkoutTemplateModel template) {
    final created = template.copyWith(
      id: 'template_${_idCounter++}',
      createdAt: DateTime.now(),
    );
    _templates.add(created);
    return created;
  }

  /// Updates an existing template.
  WorkoutTemplateModel? updateTemplate(WorkoutTemplateModel template) {
    final index = _templates.indexWhere((t) => t.id == template.id);
    if (index == -1) return null;
    final updated = template.copyWith(updatedAt: DateTime.now());
    _templates[index] = updated;
    return updated;
  }

  /// Deletes a template by ID. Returns true if found and deleted.
  bool deleteTemplate(String id) {
    final index = _templates.indexWhere((t) => t.id == id);
    if (index == -1) return false;
    _templates.removeAt(index);
    return true;
  }

  /// Returns a template by ID.
  WorkoutTemplateModel? getById(String id) {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 3 User Templates: Push, Pull, Leg Day
  // ---------------------------------------------------------------------------
  List<WorkoutTemplateModel> _buildUserTemplates() {
    final now = DateTime.now();
    return [
      WorkoutTemplateModel(
        id: 'user_template_push',
        userId: null, // available for any user
        name: 'Push Day',
        description: 'Chest, shoulders, and triceps focused workout',
        targetMuscles: ['Chest', 'Shoulders', 'Triceps'],
        estimatedMinutes: 60,
        exercises: const [
          TemplateExercise(
            exerciseId: 'ex_barbell_bench_press',
            exerciseName: 'Barbell Bench Press',
            order: 0,
            targetSets: 4,
            targetReps: '6-8',
            restSeconds: 120,
          ),
          TemplateExercise(
            exerciseId: 'ex_incline_bench_press',
            exerciseName: 'Incline Barbell Bench Press',
            order: 1,
            targetSets: 3,
            targetReps: '8-10',
            restSeconds: 90,
          ),
          TemplateExercise(
            exerciseId: 'ex_overhead_press',
            exerciseName: 'Overhead Press',
            order: 2,
            targetSets: 3,
            targetReps: '8-10',
            restSeconds: 90,
          ),
          TemplateExercise(
            exerciseId: 'ex_cable_flyes',
            exerciseName: 'Cable Flyes',
            order: 3,
            targetSets: 3,
            targetReps: '12-15',
            restSeconds: 60,
          ),
          TemplateExercise(
            exerciseId: 'ex_lateral_raise',
            exerciseName: 'Dumbbell Lateral Raise',
            order: 4,
            targetSets: 3,
            targetReps: '12-15',
            restSeconds: 60,
          ),
          TemplateExercise(
            exerciseId: 'ex_tricep_pushdown',
            exerciseName: 'Tricep Cable Pushdown',
            order: 5,
            targetSets: 3,
            targetReps: '10-12',
            restSeconds: 60,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      WorkoutTemplateModel(
        id: 'user_template_pull',
        userId: null,
        name: 'Pull Day',
        description: 'Back and biceps focused workout',
        targetMuscles: ['Back', 'Biceps'],
        estimatedMinutes: 55,
        exercises: const [
          TemplateExercise(
            exerciseId: 'ex_barbell_row',
            exerciseName: 'Barbell Bent-Over Row',
            order: 0,
            targetSets: 4,
            targetReps: '6-8',
            restSeconds: 120,
          ),
          TemplateExercise(
            exerciseId: 'ex_pull_ups',
            exerciseName: 'Pull-Ups',
            order: 1,
            targetSets: 3,
            targetReps: '8-10',
            restSeconds: 90,
          ),
          TemplateExercise(
            exerciseId: 'ex_seated_cable_row',
            exerciseName: 'Seated Cable Row',
            order: 2,
            targetSets: 3,
            targetReps: '10-12',
            restSeconds: 90,
          ),
          TemplateExercise(
            exerciseId: 'ex_face_pull',
            exerciseName: 'Face Pull',
            order: 3,
            targetSets: 3,
            targetReps: '15-20',
            restSeconds: 60,
          ),
          TemplateExercise(
            exerciseId: 'ex_barbell_curl',
            exerciseName: 'Barbell Curl',
            order: 4,
            targetSets: 3,
            targetReps: '10-12',
            restSeconds: 60,
          ),
          TemplateExercise(
            exerciseId: 'ex_hammer_curl',
            exerciseName: 'Hammer Curl',
            order: 5,
            targetSets: 3,
            targetReps: '10-12',
            restSeconds: 60,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      WorkoutTemplateModel(
        id: 'user_template_legs',
        userId: null,
        name: 'Leg Day',
        description: 'Full lower body workout with compound and isolation work',
        targetMuscles: ['Quads', 'Hamstrings', 'Glutes', 'Calves'],
        estimatedMinutes: 65,
        exercises: const [
          TemplateExercise(
            exerciseId: 'ex_barbell_squat',
            exerciseName: 'Barbell Back Squat',
            order: 0,
            targetSets: 4,
            targetReps: '6-8',
            restSeconds: 150,
          ),
          TemplateExercise(
            exerciseId: 'ex_romanian_deadlift',
            exerciseName: 'Romanian Deadlift',
            order: 1,
            targetSets: 3,
            targetReps: '8-10',
            restSeconds: 120,
          ),
          TemplateExercise(
            exerciseId: 'ex_leg_press',
            exerciseName: 'Leg Press',
            order: 2,
            targetSets: 3,
            targetReps: '10-12',
            restSeconds: 90,
          ),
          TemplateExercise(
            exerciseId: 'ex_leg_curl',
            exerciseName: 'Lying Leg Curl',
            order: 3,
            targetSets: 3,
            targetReps: '10-12',
            restSeconds: 60,
          ),
          TemplateExercise(
            exerciseId: 'ex_leg_extension',
            exerciseName: 'Leg Extension',
            order: 4,
            targetSets: 3,
            targetReps: '12-15',
            restSeconds: 60,
          ),
          TemplateExercise(
            exerciseId: 'ex_standing_calf_raise',
            exerciseName: 'Standing Calf Raise',
            order: 5,
            targetSets: 4,
            targetReps: '12-15',
            restSeconds: 60,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  // 4 System Templates: PPL, Upper/Lower, Full Body, Strength Builder
  // ---------------------------------------------------------------------------
  List<WorkoutTemplateModel> _buildSystemTemplates() {
    final now = DateTime.now();
    return [
      WorkoutTemplateModel(
        id: 'system_template_ppl',
        name: 'PPL - Push/Pull/Legs',
        description:
            'Classic push/pull/legs split. Run 3 or 6 days per week for optimal results.',
        targetMuscles: ['Chest', 'Back', 'Shoulders', 'Quads', 'Hamstrings'],
        estimatedMinutes: 60,
        isSystem: true,
        exercises: const [
          TemplateExercise(
            exerciseId: 'ex_barbell_bench_press',
            exerciseName: 'Barbell Bench Press',
            order: 0,
            targetSets: 4,
            targetReps: '6-8',
            restSeconds: 120,
          ),
          TemplateExercise(
            exerciseId: 'ex_barbell_row',
            exerciseName: 'Barbell Bent-Over Row',
            order: 1,
            targetSets: 4,
            targetReps: '6-8',
            restSeconds: 120,
          ),
          TemplateExercise(
            exerciseId: 'ex_barbell_squat',
            exerciseName: 'Barbell Back Squat',
            order: 2,
            targetSets: 4,
            targetReps: '6-8',
            restSeconds: 150,
          ),
          TemplateExercise(
            exerciseId: 'ex_overhead_press',
            exerciseName: 'Overhead Press',
            order: 3,
            targetSets: 3,
            targetReps: '8-10',
            restSeconds: 90,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 365)),
      ),
      WorkoutTemplateModel(
        id: 'system_template_upper_lower',
        name: 'Upper/Lower Split',
        description:
            'Alternating upper and lower body days. Great for 4-day training weeks.',
        targetMuscles: ['Chest', 'Back', 'Shoulders', 'Quads', 'Hamstrings'],
        estimatedMinutes: 55,
        isSystem: true,
        exercises: const [
          TemplateExercise(
            exerciseId: 'ex_incline_bench_press',
            exerciseName: 'Incline Barbell Bench Press',
            order: 0,
            targetSets: 4,
            targetReps: '8-10',
            restSeconds: 90,
          ),
          TemplateExercise(
            exerciseId: 'ex_lat_pulldown',
            exerciseName: 'Lat Pulldown',
            order: 1,
            targetSets: 4,
            targetReps: '8-10',
            restSeconds: 90,
          ),
          TemplateExercise(
            exerciseId: 'ex_overhead_press',
            exerciseName: 'Overhead Press',
            order: 2,
            targetSets: 3,
            targetReps: '8-10',
            restSeconds: 90,
          ),
          TemplateExercise(
            exerciseId: 'ex_barbell_squat',
            exerciseName: 'Barbell Back Squat',
            order: 3,
            targetSets: 4,
            targetReps: '6-8',
            restSeconds: 150,
          ),
          TemplateExercise(
            exerciseId: 'ex_romanian_deadlift',
            exerciseName: 'Romanian Deadlift',
            order: 4,
            targetSets: 3,
            targetReps: '8-10',
            restSeconds: 120,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 365)),
      ),
      WorkoutTemplateModel(
        id: 'system_template_full_body',
        name: 'Full Body Workout',
        description:
            'Hit every major muscle group in one session. Ideal for 3-day weeks or beginners.',
        targetMuscles: ['Full Body'],
        estimatedMinutes: 60,
        isSystem: true,
        exercises: const [
          TemplateExercise(
            exerciseId: 'ex_barbell_squat',
            exerciseName: 'Barbell Back Squat',
            order: 0,
            targetSets: 3,
            targetReps: '8-10',
            restSeconds: 120,
          ),
          TemplateExercise(
            exerciseId: 'ex_barbell_bench_press',
            exerciseName: 'Barbell Bench Press',
            order: 1,
            targetSets: 3,
            targetReps: '8-10',
            restSeconds: 90,
          ),
          TemplateExercise(
            exerciseId: 'ex_barbell_row',
            exerciseName: 'Barbell Bent-Over Row',
            order: 2,
            targetSets: 3,
            targetReps: '8-10',
            restSeconds: 90,
          ),
          TemplateExercise(
            exerciseId: 'ex_overhead_press',
            exerciseName: 'Overhead Press',
            order: 3,
            targetSets: 3,
            targetReps: '8-10',
            restSeconds: 90,
          ),
          TemplateExercise(
            exerciseId: 'ex_romanian_deadlift',
            exerciseName: 'Romanian Deadlift',
            order: 4,
            targetSets: 3,
            targetReps: '10-12',
            restSeconds: 90,
          ),
          TemplateExercise(
            exerciseId: 'ex_plank',
            exerciseName: 'Plank',
            order: 5,
            targetSets: 3,
            targetReps: '30-60s',
            restSeconds: 60,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 365)),
      ),
      WorkoutTemplateModel(
        id: 'system_template_strength',
        name: 'Strength Builder',
        description:
            'Low rep, heavy weight focus on the big 3 lifts. For intermediate to advanced lifters.',
        targetMuscles: ['Chest', 'Back', 'Quads'],
        estimatedMinutes: 70,
        isSystem: true,
        exercises: const [
          TemplateExercise(
            exerciseId: 'ex_barbell_squat',
            exerciseName: 'Barbell Back Squat',
            order: 0,
            targetSets: 5,
            targetReps: '3-5',
            restSeconds: 180,
          ),
          TemplateExercise(
            exerciseId: 'ex_barbell_bench_press',
            exerciseName: 'Barbell Bench Press',
            order: 1,
            targetSets: 5,
            targetReps: '3-5',
            restSeconds: 180,
          ),
          TemplateExercise(
            exerciseId: 'ex_deadlift',
            exerciseName: 'Conventional Deadlift',
            order: 2,
            targetSets: 3,
            targetReps: '3-5',
            restSeconds: 180,
          ),
          TemplateExercise(
            exerciseId: 'ex_close_grip_bench',
            exerciseName: 'Close-Grip Bench Press',
            order: 3,
            targetSets: 3,
            targetReps: '6-8',
            restSeconds: 120,
          ),
          TemplateExercise(
            exerciseId: 'ex_barbell_row',
            exerciseName: 'Barbell Bent-Over Row',
            order: 4,
            targetSets: 3,
            targetReps: '6-8',
            restSeconds: 120,
          ),
        ],
        createdAt: now.subtract(const Duration(days: 365)),
      ),
    ];
  }
}

final templateRepositoryProvider =
    Provider<TemplateRepository>((ref) => TemplateRepository());
