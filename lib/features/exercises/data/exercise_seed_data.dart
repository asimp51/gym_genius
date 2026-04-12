import '../domain/exercise_model.dart';
import 'exercises_chest.dart';
import 'exercises_back.dart';
import 'exercises_shoulders.dart';
import 'exercises_biceps.dart';
import 'exercises_triceps.dart';
import 'exercises_legs.dart';
import 'exercises_core.dart';
import 'exercises_cardio.dart';
import 'exercises_full_body.dart';
import 'exercises_stretching.dart';
import 'exercises_machines.dart';
import 'exercises_bodyweight.dart';
import 'exercises_olympic.dart';
import 'exercises_kettlebell.dart';
import 'exercises_resistance_bands.dart';

/// Master seed data — combines all exercise categories into a single library.
/// Currently shipping with 1500+ exercises across all muscle groups,
/// equipment types, and difficulty levels.
class ExerciseSeedData {
  ExerciseSeedData._();

  /// All exercises across every category. Lazily computed and cached.
  static List<ExerciseModel>? _cached;

  static List<ExerciseModel> get all {
    _cached ??= _buildAll();
    return _cached!;
  }

  static List<ExerciseModel> _buildAll() {
    return [
      ...ChestExercises.all,
      ...BackExercises.all,
      ...ShoulderExercises.all,
      ...BicepsExercises.all,
      ...TricepsExercises.all,
      ...LegExercises.all,
      ...CoreExercises.all,
      ...CardioExercises.all,
      ...FullBodyExercises.all,
      ...StretchingExercises.all,
      ...MachineExercises.all,
      ...BodyweightExercises.all,
      ...OlympicExercises.all,
      ...KettlebellExercises.all,
      ...ResistanceBandExercises.all,
    ];
  }

  /// Total count of exercises in the library.
  static int get count => all.length;

  /// Get exercises by primary muscle group.
  static List<ExerciseModel> byMuscle(String muscle) {
    final lower = muscle.toLowerCase();
    return all.where((e) =>
        e.primaryMuscles.any((m) => m.toLowerCase() == lower) ||
        e.secondaryMuscles.any((m) => m.toLowerCase() == lower)).toList();
  }

  /// Get exercises by equipment.
  static List<ExerciseModel> byEquipment(String equipment) {
    final lower = equipment.toLowerCase();
    return all.where((e) =>
        e.equipment.any((eq) => eq.toLowerCase() == lower)).toList();
  }

  /// Get exercises by difficulty.
  static List<ExerciseModel> byDifficulty(String difficulty) {
    final lower = difficulty.toLowerCase();
    return all.where((e) => e.difficulty.toLowerCase() == lower).toList();
  }

  /// Get exercises by category (strength, cardio, stretching, plyometric).
  static List<ExerciseModel> byCategory(String category) {
    final lower = category.toLowerCase();
    return all.where((e) => e.category.toLowerCase() == lower).toList();
  }

  /// Compound exercises only.
  static List<ExerciseModel> get compounds => all.where((e) => e.isCompound).toList();

  /// Isolation exercises only.
  static List<ExerciseModel> get isolations => all.where((e) => !e.isCompound).toList();

  /// Search exercises by name or search terms (fuzzy).
  static List<ExerciseModel> search(String query) {
    if (query.isEmpty) return all;
    final lower = query.toLowerCase();
    return all.where((e) {
      if (e.name.toLowerCase().contains(lower)) return true;
      if (e.searchTerms.any((t) => t.toLowerCase().contains(lower))) return true;
      return false;
    }).toList();
  }
}
