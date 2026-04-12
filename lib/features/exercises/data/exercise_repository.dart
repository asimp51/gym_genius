import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/exercise_model.dart';

/// In-memory exercise library with seed data.
/// Will be replaced by Firestore collection.
class ExerciseRepository {
  late final List<ExerciseModel> _exercises;

  ExerciseRepository() {
    _exercises = _buildSeedExercises();
  }

  /// Returns all exercises in the library.
  List<ExerciseModel> getAll() => List.unmodifiable(_exercises);

  /// Returns an exercise by its ID, or null if not found.
  ExerciseModel? getById(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Fuzzy search by name and search terms.
  /// Returns exercises whose name or searchTerms contain any word in the query.
  List<ExerciseModel> searchExercises(String query) {
    if (query.trim().isEmpty) return getAll();
    final terms = query.toLowerCase().split(RegExp(r'\s+'));
    return _exercises.where((exercise) {
      final name = exercise.name.toLowerCase();
      final searchTerms = exercise.searchTerms.map((t) => t.toLowerCase()).toList();
      return terms.every((term) {
        if (name.contains(term)) return true;
        return searchTerms.any((st) => st.contains(term));
      });
    }).toList();
  }

  /// Returns exercises that target a given muscle group (primary or secondary).
  List<ExerciseModel> getByMuscleGroup(String muscle) {
    final m = muscle.toLowerCase();
    return _exercises.where((e) {
      return e.primaryMuscles.any((pm) => pm.toLowerCase() == m) ||
          e.secondaryMuscles.any((sm) => sm.toLowerCase() == m);
    }).toList();
  }

  /// Returns exercises that use a given equipment type.
  List<ExerciseModel> getByEquipment(String equipment) {
    final eq = equipment.toLowerCase();
    return _exercises.where((e) {
      return e.equipment.any((item) => item.toLowerCase() == eq);
    }).toList();
  }

  /// Returns exercises filtered by difficulty level.
  List<ExerciseModel> getByDifficulty(String difficulty) {
    final d = difficulty.toLowerCase();
    return _exercises.where((e) => e.difficulty.toLowerCase() == d).toList();
  }

  /// Combined filtering with optional parameters.
  List<ExerciseModel> getFiltered({
    String? muscle,
    String? equipment,
    String? difficulty,
    String? query,
  }) {
    List<ExerciseModel> results = List.from(_exercises);

    if (query != null && query.trim().isNotEmpty) {
      final terms = query.toLowerCase().split(RegExp(r'\s+'));
      results = results.where((exercise) {
        final name = exercise.name.toLowerCase();
        final searchTerms =
            exercise.searchTerms.map((t) => t.toLowerCase()).toList();
        return terms.every((term) {
          if (name.contains(term)) return true;
          return searchTerms.any((st) => st.contains(term));
        });
      }).toList();
    }

    if (muscle != null && muscle.isNotEmpty) {
      final m = muscle.toLowerCase();
      results = results.where((e) {
        return e.primaryMuscles.any((pm) => pm.toLowerCase() == m) ||
            e.secondaryMuscles.any((sm) => sm.toLowerCase() == m);
      }).toList();
    }

    if (equipment != null && equipment.isNotEmpty) {
      final eq = equipment.toLowerCase();
      results = results.where((e) {
        return e.equipment.any((item) => item.toLowerCase() == eq);
      }).toList();
    }

    if (difficulty != null && difficulty.isNotEmpty) {
      final d = difficulty.toLowerCase();
      results = results.where((e) => e.difficulty.toLowerCase() == d).toList();
    }

    return results;
  }

  // ---------------------------------------------------------------------------
  // Seed Data — 30 real exercises covering all muscle groups
  // ---------------------------------------------------------------------------
  List<ExerciseModel> _buildSeedExercises() {
    return [
      // CHEST
      const ExerciseModel(
        id: 'ex_barbell_bench_press',
        name: 'Barbell Bench Press',
        slug: 'barbell-bench-press',
        primaryMuscles: ['Chest'],
        secondaryMuscles: ['Triceps', 'Shoulders'],
        category: 'strength',
        equipment: ['Barbell', 'Bench'],
        movementPattern: 'push',
        difficulty: 'intermediate',
        instructions: [
          'Lie flat on a bench with feet on the floor.',
          'Grip the barbell slightly wider than shoulder width.',
          'Unrack the bar and lower it to your mid-chest.',
          'Press the bar back up to full extension.',
        ],
        tips: [
          'Keep your shoulder blades retracted.',
          'Maintain a slight arch in your lower back.',
          'Drive through your feet for leg drive.',
        ],
        isCompound: true,
        searchTerms: ['bench', 'press', 'chest', 'barbell', 'flat bench'],
      ),
      const ExerciseModel(
        id: 'ex_dumbbell_bench_press',
        name: 'Dumbbell Bench Press',
        slug: 'dumbbell-bench-press',
        primaryMuscles: ['Chest'],
        secondaryMuscles: ['Triceps', 'Shoulders'],
        category: 'strength',
        equipment: ['Dumbbell', 'Bench'],
        movementPattern: 'push',
        difficulty: 'beginner',
        instructions: [
          'Lie on a flat bench holding a dumbbell in each hand.',
          'Press the dumbbells up until arms are extended.',
          'Lower the weights to chest level with control.',
          'Press back up to the starting position.',
        ],
        tips: [
          'Greater range of motion than barbell.',
          'Keep wrists neutral throughout the movement.',
        ],
        isCompound: true,
        searchTerms: ['dumbbell', 'bench', 'press', 'chest', 'db'],
      ),
      const ExerciseModel(
        id: 'ex_incline_bench_press',
        name: 'Incline Barbell Bench Press',
        slug: 'incline-barbell-bench-press',
        primaryMuscles: ['Chest'],
        secondaryMuscles: ['Shoulders', 'Triceps'],
        category: 'strength',
        equipment: ['Barbell', 'Bench'],
        movementPattern: 'push',
        difficulty: 'intermediate',
        instructions: [
          'Set the bench to a 30-45 degree incline.',
          'Grip the bar slightly wider than shoulder width.',
          'Lower the bar to your upper chest.',
          'Press back up to lockout.',
        ],
        tips: [
          'Targets the upper chest more than flat bench.',
          'Keep elbows at about 45 degrees.',
        ],
        isCompound: true,
        searchTerms: ['incline', 'bench', 'press', 'upper chest', 'barbell'],
      ),
      const ExerciseModel(
        id: 'ex_cable_flyes',
        name: 'Cable Flyes',
        slug: 'cable-flyes',
        primaryMuscles: ['Chest'],
        secondaryMuscles: ['Shoulders'],
        category: 'strength',
        equipment: ['Cable Machine'],
        movementPattern: 'isolation',
        difficulty: 'beginner',
        instructions: [
          'Set pulleys at chest height.',
          'Step forward with handles in each hand.',
          'Bring hands together in a hugging motion.',
          'Slowly return to the starting position.',
        ],
        tips: [
          'Maintain a slight bend in the elbows throughout.',
          'Squeeze at the peak contraction.',
        ],
        isCompound: false,
        searchTerms: ['cable', 'flyes', 'fly', 'chest', 'pec'],
      ),

      // BACK
      const ExerciseModel(
        id: 'ex_barbell_row',
        name: 'Barbell Bent-Over Row',
        slug: 'barbell-bent-over-row',
        primaryMuscles: ['Back'],
        secondaryMuscles: ['Biceps', 'Core'],
        category: 'strength',
        equipment: ['Barbell'],
        movementPattern: 'pull',
        difficulty: 'intermediate',
        instructions: [
          'Hinge at the hips with a slight knee bend.',
          'Grip the barbell with an overhand grip.',
          'Pull the bar to your lower chest/upper abdomen.',
          'Lower with control.',
        ],
        tips: [
          'Keep your back flat, not rounded.',
          'Squeeze your shoulder blades at the top.',
        ],
        isCompound: true,
        searchTerms: ['row', 'barbell', 'back', 'bent over', 'bent-over'],
      ),
      const ExerciseModel(
        id: 'ex_pull_ups',
        name: 'Pull-Ups',
        slug: 'pull-ups',
        primaryMuscles: ['Back'],
        secondaryMuscles: ['Biceps', 'Forearms'],
        category: 'strength',
        equipment: ['Pull-Up Bar'],
        movementPattern: 'pull',
        difficulty: 'intermediate',
        instructions: [
          'Hang from a bar with an overhand grip wider than shoulders.',
          'Pull yourself up until your chin clears the bar.',
          'Lower yourself back down with control.',
        ],
        tips: [
          'Avoid swinging or kipping.',
          'Engage your lats before pulling.',
        ],
        isCompound: true,
        searchTerms: ['pull', 'up', 'pullup', 'chin', 'back', 'lats'],
      ),
      const ExerciseModel(
        id: 'ex_lat_pulldown',
        name: 'Lat Pulldown',
        slug: 'lat-pulldown',
        primaryMuscles: ['Back'],
        secondaryMuscles: ['Biceps'],
        category: 'strength',
        equipment: ['Cable Machine'],
        movementPattern: 'pull',
        difficulty: 'beginner',
        instructions: [
          'Sit at a lat pulldown machine and grasp the bar wide.',
          'Pull the bar down to your upper chest.',
          'Slowly return to the starting position.',
        ],
        tips: [
          'Lean back slightly but do not swing.',
          'Focus on pulling with your elbows.',
        ],
        isCompound: true,
        searchTerms: ['lat', 'pulldown', 'pull', 'down', 'back', 'cable'],
      ),
      const ExerciseModel(
        id: 'ex_seated_cable_row',
        name: 'Seated Cable Row',
        slug: 'seated-cable-row',
        primaryMuscles: ['Back'],
        secondaryMuscles: ['Biceps', 'Core'],
        category: 'strength',
        equipment: ['Cable Machine'],
        movementPattern: 'pull',
        difficulty: 'beginner',
        instructions: [
          'Sit at a cable row station with feet on the platform.',
          'Grasp the handle and pull it to your abdomen.',
          'Keep your torso upright.',
          'Return with control.',
        ],
        tips: [
          'Avoid leaning too far forward or backward.',
          'Squeeze your back muscles at peak contraction.',
        ],
        isCompound: true,
        searchTerms: ['seated', 'cable', 'row', 'back', 'mid back'],
      ),

      // SHOULDERS
      const ExerciseModel(
        id: 'ex_overhead_press',
        name: 'Overhead Press',
        slug: 'overhead-press',
        primaryMuscles: ['Shoulders'],
        secondaryMuscles: ['Triceps', 'Core'],
        category: 'strength',
        equipment: ['Barbell'],
        movementPattern: 'push',
        difficulty: 'intermediate',
        instructions: [
          'Stand with feet shoulder width apart.',
          'Hold the barbell at shoulder height.',
          'Press the bar overhead until arms are locked out.',
          'Lower the bar back to shoulder height.',
        ],
        tips: [
          'Brace your core throughout the lift.',
          'Tuck your chin to let the bar pass your face.',
        ],
        isCompound: true,
        searchTerms: ['overhead', 'press', 'ohp', 'shoulder', 'military'],
      ),
      const ExerciseModel(
        id: 'ex_lateral_raise',
        name: 'Dumbbell Lateral Raise',
        slug: 'dumbbell-lateral-raise',
        primaryMuscles: ['Shoulders'],
        secondaryMuscles: [],
        category: 'strength',
        equipment: ['Dumbbell'],
        movementPattern: 'isolation',
        difficulty: 'beginner',
        instructions: [
          'Stand with dumbbells at your sides.',
          'Raise your arms out to the sides until parallel with the floor.',
          'Lower with control.',
        ],
        tips: [
          'Do not swing the weights up.',
          'Slight bend in the elbows.',
          'Lead with the elbows, not the hands.',
        ],
        isCompound: false,
        searchTerms: ['lateral', 'raise', 'side', 'shoulder', 'delt'],
      ),
      const ExerciseModel(
        id: 'ex_face_pull',
        name: 'Face Pull',
        slug: 'face-pull',
        primaryMuscles: ['Shoulders'],
        secondaryMuscles: ['Back'],
        category: 'strength',
        equipment: ['Cable Machine'],
        movementPattern: 'pull',
        difficulty: 'beginner',
        instructions: [
          'Set a cable pulley at upper chest height with a rope.',
          'Pull the rope towards your face, separating the ends.',
          'Squeeze your rear delts at the end.',
          'Return slowly.',
        ],
        tips: [
          'Great for shoulder health and posture.',
          'Keep your elbows high.',
        ],
        isCompound: false,
        searchTerms: ['face', 'pull', 'rear delt', 'shoulder', 'cable'],
      ),

      // BICEPS
      const ExerciseModel(
        id: 'ex_barbell_curl',
        name: 'Barbell Curl',
        slug: 'barbell-curl',
        primaryMuscles: ['Biceps'],
        secondaryMuscles: ['Forearms'],
        category: 'strength',
        equipment: ['Barbell'],
        movementPattern: 'isolation',
        difficulty: 'beginner',
        instructions: [
          'Stand with feet shoulder width apart holding a barbell.',
          'Curl the bar up by bending at the elbows.',
          'Squeeze at the top, then lower slowly.',
        ],
        tips: [
          'Keep your upper arms stationary.',
          'Do not swing your body.',
        ],
        isCompound: false,
        searchTerms: ['curl', 'barbell', 'bicep', 'arm'],
      ),
      const ExerciseModel(
        id: 'ex_hammer_curl',
        name: 'Hammer Curl',
        slug: 'hammer-curl',
        primaryMuscles: ['Biceps'],
        secondaryMuscles: ['Forearms'],
        category: 'strength',
        equipment: ['Dumbbell'],
        movementPattern: 'isolation',
        difficulty: 'beginner',
        instructions: [
          'Hold dumbbells with palms facing your body.',
          'Curl up while keeping the neutral grip.',
          'Lower with control.',
        ],
        tips: [
          'Targets the brachialis and forearms more.',
          'Alternate arms or curl both at once.',
        ],
        isCompound: false,
        searchTerms: ['hammer', 'curl', 'bicep', 'brachialis', 'dumbbell'],
      ),

      // TRICEPS
      const ExerciseModel(
        id: 'ex_tricep_pushdown',
        name: 'Tricep Cable Pushdown',
        slug: 'tricep-cable-pushdown',
        primaryMuscles: ['Triceps'],
        secondaryMuscles: [],
        category: 'strength',
        equipment: ['Cable Machine'],
        movementPattern: 'isolation',
        difficulty: 'beginner',
        instructions: [
          'Stand at a cable station with a straight or V-bar.',
          'Push the bar down by extending your elbows.',
          'Squeeze your triceps at the bottom.',
          'Return to starting position slowly.',
        ],
        tips: [
          'Keep your elbows pinned to your sides.',
          'Do not lean forward excessively.',
        ],
        isCompound: false,
        searchTerms: ['tricep', 'pushdown', 'push', 'cable', 'arm'],
      ),
      const ExerciseModel(
        id: 'ex_close_grip_bench',
        name: 'Close-Grip Bench Press',
        slug: 'close-grip-bench-press',
        primaryMuscles: ['Triceps'],
        secondaryMuscles: ['Chest', 'Shoulders'],
        category: 'strength',
        equipment: ['Barbell', 'Bench'],
        movementPattern: 'push',
        difficulty: 'intermediate',
        instructions: [
          'Lie on a flat bench and grip the bar shoulder width.',
          'Lower the bar to your lower chest.',
          'Press up focusing on tricep contraction.',
        ],
        tips: [
          'Grip should be shoulder width, not too narrow.',
          'Keep elbows close to your body.',
        ],
        isCompound: true,
        searchTerms: ['close grip', 'bench', 'tricep', 'press', 'cgbp'],
      ),

      // QUADS
      const ExerciseModel(
        id: 'ex_barbell_squat',
        name: 'Barbell Back Squat',
        slug: 'barbell-back-squat',
        primaryMuscles: ['Quads'],
        secondaryMuscles: ['Glutes', 'Hamstrings', 'Core'],
        category: 'strength',
        equipment: ['Barbell'],
        movementPattern: 'squat',
        difficulty: 'intermediate',
        instructions: [
          'Place the barbell on your upper traps.',
          'Unrack and step back with feet shoulder width apart.',
          'Squat down until thighs are at least parallel.',
          'Drive up through your heels.',
        ],
        tips: [
          'Keep your chest up and core braced.',
          'Knees should track over toes.',
          'Do not let your lower back round.',
        ],
        isCompound: true,
        searchTerms: ['squat', 'barbell', 'back squat', 'legs', 'quads'],
      ),
      const ExerciseModel(
        id: 'ex_leg_press',
        name: 'Leg Press',
        slug: 'leg-press',
        primaryMuscles: ['Quads'],
        secondaryMuscles: ['Glutes', 'Hamstrings'],
        category: 'strength',
        equipment: ['Smith Machine'],
        movementPattern: 'squat',
        difficulty: 'beginner',
        instructions: [
          'Sit in the leg press machine with feet shoulder width on the platform.',
          'Lower the platform by bending your knees to 90 degrees.',
          'Press back up without locking out your knees.',
        ],
        tips: [
          'Do not let your lower back lift off the seat.',
          'Foot placement affects muscle emphasis.',
        ],
        isCompound: true,
        searchTerms: ['leg', 'press', 'quads', 'legs', 'machine'],
      ),
      const ExerciseModel(
        id: 'ex_leg_extension',
        name: 'Leg Extension',
        slug: 'leg-extension',
        primaryMuscles: ['Quads'],
        secondaryMuscles: [],
        category: 'strength',
        equipment: ['Cable Machine'],
        movementPattern: 'isolation',
        difficulty: 'beginner',
        instructions: [
          'Sit on the leg extension machine.',
          'Extend your legs until straight.',
          'Lower back with control.',
        ],
        tips: [
          'Do not use momentum.',
          'Squeeze at full extension.',
        ],
        isCompound: false,
        searchTerms: ['leg', 'extension', 'quads', 'quad', 'machine'],
      ),

      // HAMSTRINGS
      const ExerciseModel(
        id: 'ex_romanian_deadlift',
        name: 'Romanian Deadlift',
        slug: 'romanian-deadlift',
        primaryMuscles: ['Hamstrings'],
        secondaryMuscles: ['Glutes', 'Back'],
        category: 'strength',
        equipment: ['Barbell'],
        movementPattern: 'hinge',
        difficulty: 'intermediate',
        instructions: [
          'Stand with feet hip width, holding a barbell at hip height.',
          'Push your hips back while lowering the bar along your legs.',
          'Lower until you feel a stretch in your hamstrings.',
          'Drive hips forward to return to standing.',
        ],
        tips: [
          'Keep the bar close to your body.',
          'Maintain a slight knee bend throughout.',
          'Do not round your lower back.',
        ],
        isCompound: true,
        searchTerms: ['romanian', 'deadlift', 'rdl', 'hamstring', 'hinge'],
      ),
      const ExerciseModel(
        id: 'ex_leg_curl',
        name: 'Lying Leg Curl',
        slug: 'lying-leg-curl',
        primaryMuscles: ['Hamstrings'],
        secondaryMuscles: ['Calves'],
        category: 'strength',
        equipment: ['Cable Machine'],
        movementPattern: 'isolation',
        difficulty: 'beginner',
        instructions: [
          'Lie face down on the leg curl machine.',
          'Curl the pad toward your glutes.',
          'Lower with control.',
        ],
        tips: [
          'Do not lift your hips off the pad.',
          'Control the eccentric (lowering) phase.',
        ],
        isCompound: false,
        searchTerms: ['leg', 'curl', 'hamstring', 'lying', 'machine'],
      ),

      // GLUTES
      const ExerciseModel(
        id: 'ex_hip_thrust',
        name: 'Barbell Hip Thrust',
        slug: 'barbell-hip-thrust',
        primaryMuscles: ['Glutes'],
        secondaryMuscles: ['Hamstrings', 'Core'],
        category: 'strength',
        equipment: ['Barbell', 'Bench'],
        movementPattern: 'hinge',
        difficulty: 'intermediate',
        instructions: [
          'Sit on the ground with your upper back against a bench.',
          'Roll a barbell over your hips.',
          'Drive your hips up until your body forms a straight line.',
          'Squeeze your glutes at the top, then lower.',
        ],
        tips: [
          'Keep your chin tucked.',
          'Push through your heels.',
        ],
        isCompound: true,
        searchTerms: ['hip', 'thrust', 'glute', 'barbell', 'bridge'],
      ),

      // CALVES
      const ExerciseModel(
        id: 'ex_standing_calf_raise',
        name: 'Standing Calf Raise',
        slug: 'standing-calf-raise',
        primaryMuscles: ['Calves'],
        secondaryMuscles: [],
        category: 'strength',
        equipment: ['Smith Machine'],
        movementPattern: 'isolation',
        difficulty: 'beginner',
        instructions: [
          'Stand on the edge of a step or calf raise machine.',
          'Rise up onto your toes as high as possible.',
          'Lower your heels below the platform for a full stretch.',
        ],
        tips: [
          'Pause at the top of each rep.',
          'Full range of motion is key for calf development.',
        ],
        isCompound: false,
        searchTerms: ['calf', 'calves', 'raise', 'standing', 'lower leg'],
      ),

      // CORE
      const ExerciseModel(
        id: 'ex_plank',
        name: 'Plank',
        slug: 'plank',
        primaryMuscles: ['Core'],
        secondaryMuscles: ['Shoulders'],
        category: 'strength',
        equipment: ['Bodyweight'],
        movementPattern: 'isolation',
        difficulty: 'beginner',
        instructions: [
          'Get into a push-up position on your forearms.',
          'Keep your body in a straight line from head to heels.',
          'Hold the position for the prescribed time.',
        ],
        tips: [
          'Do not let your hips sag or pike up.',
          'Breathe steadily.',
        ],
        isCompound: false,
        searchTerms: ['plank', 'core', 'abs', 'bodyweight', 'isometric'],
      ),
      const ExerciseModel(
        id: 'ex_cable_crunch',
        name: 'Cable Crunch',
        slug: 'cable-crunch',
        primaryMuscles: ['Core'],
        secondaryMuscles: [],
        category: 'strength',
        equipment: ['Cable Machine'],
        movementPattern: 'isolation',
        difficulty: 'beginner',
        instructions: [
          'Kneel facing a cable machine with a rope attachment.',
          'Hold the rope behind your head.',
          'Crunch down, bringing your elbows toward your knees.',
          'Return to the starting position slowly.',
        ],
        tips: [
          'Focus on flexing your spine, not pulling with your arms.',
          'Use moderate weight for high reps.',
        ],
        isCompound: false,
        searchTerms: ['cable', 'crunch', 'abs', 'core', 'abdominal'],
      ),

      // COMPOUND / FULL BODY
      const ExerciseModel(
        id: 'ex_deadlift',
        name: 'Conventional Deadlift',
        slug: 'conventional-deadlift',
        primaryMuscles: ['Back', 'Hamstrings'],
        secondaryMuscles: ['Glutes', 'Core', 'Quads', 'Forearms'],
        category: 'strength',
        equipment: ['Barbell'],
        movementPattern: 'hinge',
        difficulty: 'advanced',
        instructions: [
          'Stand with feet hip width, bar over mid-foot.',
          'Grip the bar just outside your knees.',
          'Brace your core and drive through the floor.',
          'Stand up tall, locking out hips and knees.',
          'Lower the bar back to the floor with control.',
        ],
        tips: [
          'Keep the bar close to your body throughout.',
          'Do not round your lower back.',
          'Think of pushing the floor away.',
        ],
        isCompound: true,
        searchTerms: ['deadlift', 'conventional', 'back', 'full body', 'hinge'],
      ),
      const ExerciseModel(
        id: 'ex_dumbbell_lunge',
        name: 'Dumbbell Walking Lunge',
        slug: 'dumbbell-walking-lunge',
        primaryMuscles: ['Quads'],
        secondaryMuscles: ['Glutes', 'Hamstrings', 'Core'],
        category: 'strength',
        equipment: ['Dumbbell'],
        movementPattern: 'squat',
        difficulty: 'intermediate',
        instructions: [
          'Hold a dumbbell in each hand at your sides.',
          'Step forward into a lunge, lowering your back knee.',
          'Push off your front foot and step the other foot forward.',
          'Continue walking forward alternating legs.',
        ],
        tips: [
          'Keep your torso upright.',
          'Front knee should not pass your toes excessively.',
        ],
        isCompound: true,
        searchTerms: ['lunge', 'walking', 'dumbbell', 'quads', 'legs'],
      ),
      const ExerciseModel(
        id: 'ex_dips',
        name: 'Dips',
        slug: 'dips',
        primaryMuscles: ['Triceps'],
        secondaryMuscles: ['Chest', 'Shoulders'],
        category: 'strength',
        equipment: ['Bodyweight'],
        movementPattern: 'push',
        difficulty: 'intermediate',
        instructions: [
          'Grip the parallel bars and lift yourself up.',
          'Lower your body by bending your elbows to 90 degrees.',
          'Press back up to full arm extension.',
        ],
        tips: [
          'Lean forward slightly to emphasize chest.',
          'Stay upright to emphasize triceps.',
        ],
        isCompound: true,
        searchTerms: ['dip', 'dips', 'tricep', 'chest', 'bodyweight', 'parallel bars'],
      ),
      const ExerciseModel(
        id: 'ex_push_ups',
        name: 'Push-Ups',
        slug: 'push-ups',
        primaryMuscles: ['Chest'],
        secondaryMuscles: ['Triceps', 'Shoulders', 'Core'],
        category: 'strength',
        equipment: ['Bodyweight'],
        movementPattern: 'push',
        difficulty: 'beginner',
        instructions: [
          'Start in a high plank position with hands shoulder width.',
          'Lower your body until your chest nearly touches the floor.',
          'Push back up to the starting position.',
        ],
        tips: [
          'Keep your core tight throughout.',
          'Full range of motion for best results.',
        ],
        isCompound: true,
        searchTerms: ['push', 'up', 'pushup', 'bodyweight', 'chest'],
      ),
    ];
  }
}

final exerciseRepositoryProvider =
    Provider<ExerciseRepository>((ref) => ExerciseRepository());
