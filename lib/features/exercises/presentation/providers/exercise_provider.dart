import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/exercise_repository.dart';
import '../../domain/exercise_model.dart';

// All exercises from seed data
final allExercisesProvider = Provider<List<ExerciseModel>>((ref) {
  return ref.watch(exerciseRepositoryProvider).getAll();
});

// Search query state
final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

// Selected muscle filter state
final selectedMuscleFilterProvider = StateProvider<String?>((ref) => null);

// Selected equipment filter state
final selectedEquipmentFilterProvider = StateProvider<String?>((ref) => null);

// Selected difficulty filter state
final selectedDifficultyFilterProvider = StateProvider<String?>((ref) => null);

// Filtered exercises based on all active filters
final filteredExercisesProvider = Provider<List<ExerciseModel>>((ref) {
  final repo = ref.watch(exerciseRepositoryProvider);
  final query = ref.watch(exerciseSearchQueryProvider);
  final muscle = ref.watch(selectedMuscleFilterProvider);
  final equipment = ref.watch(selectedEquipmentFilterProvider);
  final difficulty = ref.watch(selectedDifficultyFilterProvider);

  return repo.getFiltered(
    query: query.isEmpty ? null : query,
    muscle: muscle,
    equipment: equipment,
    difficulty: difficulty,
  );
});

// Single exercise by ID
final exerciseByIdProvider = Provider.family<ExerciseModel?, String>((ref, id) {
  return ref.watch(exerciseRepositoryProvider).getById(id);
});

// Exercises grouped by muscle
final exercisesByMuscleProvider = Provider<Map<String, List<ExerciseModel>>>((ref) {
  final exercises = ref.watch(allExercisesProvider);
  final grouped = <String, List<ExerciseModel>>{};

  for (final exercise in exercises) {
    for (final muscle in exercise.primaryMuscles) {
      grouped.putIfAbsent(muscle, () => []).add(exercise);
    }
  }

  return grouped;
});

// Available muscle groups from exercises
final availableMuscleGroupsProvider = Provider<List<String>>((ref) {
  final exercises = ref.watch(allExercisesProvider);
  final muscles = <String>{};
  for (final e in exercises) {
    muscles.addAll(e.primaryMuscles);
  }
  final sorted = muscles.toList()..sort();
  return ['All', ...sorted];
});

// Exercise count
final exerciseCountProvider = Provider<int>((ref) {
  return ref.watch(allExercisesProvider).length;
});
