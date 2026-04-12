import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/nutrition_repository.dart';
import '../../domain/nutrition_model.dart';

// Selected date for nutrition view
final nutritionDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Today's nutrition log
final nutritionLogProvider = Provider<NutritionLog>((ref) {
  final date = ref.watch(nutritionDateProvider);
  return ref.watch(nutritionRepositoryProvider).getLogForDate('user_1', date);
});

// Calorie progress (0.0 - 1.0)
final calorieProgressProvider = Provider<double>((ref) {
  final log = ref.watch(nutritionLogProvider);
  if (log.goals.calories <= 0) return 0;
  return (log.totals.calories / log.goals.calories).clamp(0.0, 1.5);
});

// Protein progress
final proteinProgressProvider = Provider<double>((ref) {
  final log = ref.watch(nutritionLogProvider);
  if (log.goals.protein <= 0) return 0;
  return (log.totals.protein / log.goals.protein).clamp(0.0, 1.5);
});

// Carbs progress
final carbsProgressProvider = Provider<double>((ref) {
  final log = ref.watch(nutritionLogProvider);
  if (log.goals.carbs <= 0) return 0;
  return (log.totals.carbs / log.goals.carbs).clamp(0.0, 1.5);
});

// Fat progress
final fatProgressProvider = Provider<double>((ref) {
  final log = ref.watch(nutritionLogProvider);
  if (log.goals.fat <= 0) return 0;
  return (log.totals.fat / log.goals.fat).clamp(0.0, 1.5);
});

// Food search results
final foodSearchQueryProvider = StateProvider<String>((ref) => '');

final foodSearchResultsProvider = Provider<List<FoodItem>>((ref) {
  final query = ref.watch(foodSearchQueryProvider);
  if (query.isEmpty) return [];
  return ref.watch(nutritionRepositoryProvider).searchFoods(query);
});

// Remaining macros
final remainingMacrosProvider = Provider<NutritionTotals>((ref) {
  final log = ref.watch(nutritionLogProvider);
  return NutritionTotals(
    calories: (log.goals.calories - log.totals.calories).clamp(0, double.infinity),
    protein: (log.goals.protein - log.totals.protein).clamp(0, double.infinity),
    carbs: (log.goals.carbs - log.totals.carbs).clamp(0, double.infinity),
    fat: (log.goals.fat - log.totals.fat).clamp(0, double.infinity),
  );
});
