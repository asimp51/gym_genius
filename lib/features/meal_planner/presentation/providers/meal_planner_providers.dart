import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_genius/features/meal_planner/data/meal_plan_repository.dart';
import 'package:gym_genius/features/meal_planner/domain/meal_plan_model.dart';
import 'package:gym_genius/features/meal_planner/domain/recipe_model.dart';

// Re-export so screens can get mealPlanRepositoryProvider from this file
export 'package:gym_genius/features/meal_planner/data/meal_plan_repository.dart'
    show mealPlanRepositoryProvider;

/// The currently active meal plan for the logged-in user.
final activeMealPlanProvider = Provider<MealPlan?>((ref) {
  final repo = ref.watch(mealPlanRepositoryProvider);
  return repo.getActiveMealPlan('user_1');
});

/// Today's planned meals from the active plan.
final todayMealsProvider = Provider<List<PlannedMeal>>((ref) {
  final plan = ref.watch(activeMealPlanProvider);
  if (plan == null) return [];
  final today = DateTime.now();
  final day = plan.dayFor(today);
  return day?.meals ?? [];
});

/// Draft plan produced by the AI generator, held until user confirms.
final draftMealPlanProvider = StateProvider<MealPlan?>((ref) => null);

// -------------------- Recipe browsing --------------------

final recipeSearchQueryProvider = StateProvider<String>((ref) => '');
final recipeMealTypeFilterProvider = StateProvider<String>((ref) => 'all');
final recipeDietFilterProvider = StateProvider<String>((ref) => 'all');

/// Every recipe in the seed data.
final allRecipesProvider = Provider<List<Recipe>>((ref) {
  final repo = ref.watch(mealPlanRepositoryProvider);
  return repo.getAllRecipes();
});

/// Recipes filtered by current search + meal-type + diet selections.
final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final query = ref.watch(recipeSearchQueryProvider).toLowerCase();
  final mealType = ref.watch(recipeMealTypeFilterProvider);
  final diet = ref.watch(recipeDietFilterProvider);
  final repo = ref.watch(mealPlanRepositoryProvider);

  List<Recipe> results = repo.getAllRecipes();

  // Meal type filter
  if (mealType != 'all') {
    results = results.where((r) => r.mealType == mealType).toList();
  }

  // Diet / category filter
  if (diet != 'all') {
    results = results.where((r) {
      return r.dietaryTags.contains(diet) || r.categories.contains(diet);
    }).toList();
  }

  // Search query
  if (query.isNotEmpty) {
    results = results.where((r) {
      if (r.name.toLowerCase().contains(query)) return true;
      if (r.description.toLowerCase().contains(query)) return true;
      if (r.categories.any((c) => c.toLowerCase().contains(query))) return true;
      if (r.dietaryTags.any((t) => t.toLowerCase().contains(query))) {
        return true;
      }
      if (r.ingredients.any((i) => i.name.toLowerCase().contains(query))) {
        return true;
      }
      return false;
    }).toList();
  }

  return results;
});

/// Look up a single recipe by id.
final recipeByIdProvider = Provider.family<Recipe?, String>((ref, id) {
  final repo = ref.watch(mealPlanRepositoryProvider);
  return repo.getRecipeById(id);
});

/// Recipes tagged with 'meal_prep'.
final mealPrepRecipesProvider = Provider<List<Recipe>>((ref) {
  final repo = ref.watch(mealPlanRepositoryProvider);
  return repo
      .getAllRecipes()
      .where((r) => r.categories.contains('meal_prep'))
      .take(6)
      .toList();
});
