import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/meal_plan_model.dart';
import '../domain/recipe_model.dart';
import 'recipe_seed_data.dart';

class MealPlanRepository {
  final Map<String, MealPlan> _mealPlans = {};
  final Set<String> _favoriteRecipeIds = {};
  final List<Recipe> _allRecipes = RecipeSeedData.all;
  final Random _random = Random(42);

  MealPlanRepository() {
    _seedMockMealPlan();
    _seedFavorites();
  }

  // ---------------- Meal Plans ----------------

  List<MealPlan> getMealPlans(String userId) {
    return _mealPlans.values.where((p) => p.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  MealPlan? getActiveMealPlan(String userId) {
    final plans = getMealPlans(userId);
    for (final p in plans) {
      if (p.isActive) return p;
    }
    return plans.isEmpty ? null : plans.first;
  }

  MealPlan? getMealPlanById(String id) => _mealPlans[id];

  MealPlan createMealPlan({
    required String userId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required String goal,
    required int targetCalories,
    required int targetProtein,
    required int targetCarbs,
    required int targetFat,
    required List<DietaryRestriction> restrictions,
    required List<DailyMealPlan> days,
    bool isAiGenerated = false,
  }) {
    final plan = MealPlan(
      id: 'mp_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      name: name,
      startDate: startDate,
      endDate: endDate,
      goal: goal,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      restrictions: restrictions,
      days: days,
      isAiGenerated: isAiGenerated,
      createdAt: DateTime.now(),
    );
    _mealPlans[plan.id] = plan;
    return plan;
  }

  void updateMealPlan(MealPlan plan) {
    _mealPlans[plan.id] = plan;
  }

  void deleteMealPlan(String id) {
    _mealPlans.remove(id);
  }

  void markMealCompleted(String mealId, bool completed) {
    for (final entry in _mealPlans.entries) {
      final plan = entry.value;
      bool found = false;
      final days = <DailyMealPlan>[];
      for (final day in plan.days) {
        final updatedMeals = day.meals.map((m) {
          if (m.id == mealId) {
            found = true;
            return m.copyWith(isCompleted: completed);
          }
          return m;
        }).toList();
        days.add(day.copyWith(meals: updatedMeals));
      }
      if (found) {
        _mealPlans[entry.key] = plan.copyWith(days: days);
        return;
      }
    }
  }

  Future<void> saveMealPlan(MealPlan plan) async {
    _mealPlans[plan.id] = plan;
  }

  void toggleFavorite(String recipeId) {
    toggleFavoriteRecipe(recipeId);
  }

  void addRecipeToPlan(String recipeId, String mealType, DateTime date) {
    final recipe = getRecipeById(recipeId);
    if (recipe == null) return;
    final activePlan = getActiveMealPlan('user_1');
    if (activePlan == null) return;
    final meal = _toPlannedMeal(recipe, mealType, date.day, activePlan.days.length);
    final days = <DailyMealPlan>[];
    bool added = false;
    for (final day in activePlan.days) {
      if (day.date.year == date.year &&
          day.date.month == date.month &&
          day.date.day == date.day) {
        days.add(DailyMealPlan.fromMeals(
          date: day.date,
          meals: [...day.meals, meal],
        ));
        added = true;
      } else {
        days.add(day);
      }
    }
    if (!added) {
      days.add(DailyMealPlan.fromMeals(date: date, meals: [meal]));
    }
    _mealPlans[activePlan.id] = activePlan.copyWith(days: days);
  }

  // ---------------- AI Generation ----------------

  Future<MealPlan> generateAiPlan({
    required String goal,
    required int targetCalories,
    required int targetProtein,
    required int days,
    int mealsPerDay = 4,
    List<DietaryRestriction> restrictions = const [],
    String budget = 'moderate',
    String skill = 'intermediate',
    int maxCookTime = 30,
  }) async {
    return generateAiMealPlan(
      userId: 'user_1',
      goal: goal,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      restrictions: restrictions,
      days: days,
    );
  }

  Future<MealPlan> generateAiMealPlan({
    required String userId,
    required String goal,
    required int targetCalories,
    required int targetProtein,
    required List<DietaryRestriction> restrictions,
    required int days,
  }) async {
    // Simulate network latency
    await Future<void>.delayed(const Duration(milliseconds: 1800));

    // Split targets across 3 main meals + 1 snack
    final mealCal = (targetCalories * 0.3).round();
    final snackCal = (targetCalories * 0.1).round();

    List<Recipe> filter(String type) {
      return _allRecipes.where((r) {
        if (r.mealType != type) return false;
        for (final restriction in restrictions) {
          // Basic restriction compliance check
          if (restriction == DietaryRestriction.vegetarian &&
              !r.dietaryTags.contains('vegetarian') &&
              !r.dietaryTags.contains('vegan')) {
            return false;
          }
          if (restriction == DietaryRestriction.vegan &&
              !r.dietaryTags.contains('vegan')) {
            return false;
          }
          if (restriction == DietaryRestriction.glutenFree &&
              !r.dietaryTags.contains('gluten_free')) {
            return false;
          }
          if (restriction == DietaryRestriction.dairyFree &&
              !r.dietaryTags.contains('dairy_free') &&
              !r.dietaryTags.contains('vegan')) {
            return false;
          }
          if (restriction == DietaryRestriction.paleo &&
              !r.dietaryTags.contains('paleo')) {
            return false;
          }
        }
        return true;
      }).toList();
    }

    final breakfasts = filter('breakfast');
    final lunches = filter('lunch');
    final dinners = filter('dinner');
    final snacks = filter('snack');

    // Fallback lists if filters are too restrictive
    final bList = breakfasts.isEmpty
        ? _allRecipes.where((r) => r.mealType == 'breakfast').toList()
        : breakfasts;
    final lList = lunches.isEmpty
        ? _allRecipes.where((r) => r.mealType == 'lunch').toList()
        : lunches;
    final dList = dinners.isEmpty
        ? _allRecipes.where((r) => r.mealType == 'dinner').toList()
        : dinners;
    final sList = snacks.isEmpty
        ? _allRecipes.where((r) => r.mealType == 'snack').toList()
        : snacks;

    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: days - 1));
    final dailyPlans = <DailyMealPlan>[];

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      final breakfast = _pickNearCal(bList, mealCal);
      final lunch = _pickNearCal(lList, mealCal);
      final dinner = _pickNearCal(dList, mealCal);
      final snack = _pickNearCal(sList, snackCal);

      final meals = <PlannedMeal>[
        _toPlannedMeal(breakfast, 'breakfast', i, 0),
        _toPlannedMeal(lunch, 'lunch', i, 1),
        _toPlannedMeal(dinner, 'dinner', i, 2),
        _toPlannedMeal(snack, 'snack', i, 3),
      ];

      dailyPlans.add(DailyMealPlan.fromMeals(date: date, meals: meals));
    }

    final plan = createMealPlan(
      userId: userId,
      name: _planNameForGoal(goal),
      startDate: startDate,
      endDate: endDate,
      goal: goal,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: (targetCalories * 0.45 / 4).round(),
      targetFat: (targetCalories * 0.25 / 9).round(),
      restrictions: restrictions,
      days: dailyPlans,
      isAiGenerated: true,
    );
    return plan;
  }

  Recipe _pickNearCal(List<Recipe> pool, int targetCal) {
    if (pool.isEmpty) return _allRecipes.first;
    final sorted = List<Recipe>.from(pool)
      ..sort((a, b) => (a.caloriesPerServing - targetCal)
          .abs()
          .compareTo((b.caloriesPerServing - targetCal).abs()));
    // Random pick in top 5 for variety
    final top = sorted.take(5).toList();
    return top[_random.nextInt(top.length)];
  }

  PlannedMeal _toPlannedMeal(
      Recipe recipe, String mealType, int dayIdx, int mealIdx) {
    return PlannedMeal(
      id: 'pm_${dayIdx}_${mealIdx}_${DateTime.now().microsecondsSinceEpoch}',
      mealType: mealType,
      recipeId: recipe.id,
      recipeName: recipe.name,
      servings: 1,
      calories: recipe.caloriesPerServing,
      protein: recipe.proteinPerServing.round(),
      carbs: recipe.carbsPerServing.round(),
      fat: recipe.fatPerServing.round(),
      prepTime: recipe.totalTimeMinutes,
    );
  }

  String _planNameForGoal(String goal) {
    switch (goal) {
      case 'build_muscle':
        return 'Muscle Building Plan';
      case 'lose_weight':
        return 'Fat Loss Plan';
      case 'maintain':
        return 'Maintenance Plan';
      case 'cut':
        return 'Cutting Plan';
      case 'bulk':
        return 'Bulking Plan';
      default:
        return 'Custom Meal Plan';
    }
  }

  // ---------------- Recipes ----------------

  List<Recipe> getAllRecipes() {
    return _allRecipes
        .map((r) => r.copyWith(isFavorite: _favoriteRecipeIds.contains(r.id)))
        .toList();
  }

  Recipe? getRecipeById(String id) {
    for (final r in _allRecipes) {
      if (r.id == id) {
        return r.copyWith(isFavorite: _favoriteRecipeIds.contains(r.id));
      }
    }
    return null;
  }

  List<Recipe> getRecipesByMealType(String mealType) {
    return getAllRecipes().where((r) => r.mealType == mealType).toList();
  }

  List<Recipe> getRecipesByCategory(String category) {
    return getAllRecipes()
        .where((r) => r.categories.contains(category))
        .toList();
  }

  List<Recipe> searchRecipes(String query) {
    if (query.isEmpty) return getAllRecipes();
    final q = query.toLowerCase();
    return getAllRecipes().where((r) {
      if (r.name.toLowerCase().contains(q)) return true;
      if (r.description.toLowerCase().contains(q)) return true;
      if (r.categories.any((c) => c.toLowerCase().contains(q))) return true;
      if (r.dietaryTags.any((t) => t.toLowerCase().contains(q))) return true;
      if (r.ingredients.any((i) => i.name.toLowerCase().contains(q))) {
        return true;
      }
      return false;
    }).toList();
  }

  List<Recipe> getRecipesByDietaryTag(String tag) {
    return getAllRecipes().where((r) => r.dietaryTags.contains(tag)).toList();
  }

  List<Recipe> getFavoriteRecipes(String userId) {
    return getAllRecipes().where((r) => r.isFavorite).toList();
  }

  void toggleFavoriteRecipe(String recipeId) {
    if (_favoriteRecipeIds.contains(recipeId)) {
      _favoriteRecipeIds.remove(recipeId);
    } else {
      _favoriteRecipeIds.add(recipeId);
    }
  }

  List<Recipe> getRecommendedRecipes(String userId) {
    // Recommend high-protein, well-rated, meal-prep friendly
    return getAllRecipes().where((r) {
      return r.categories.contains('high_protein') && r.rating >= 4.7;
    }).take(12).toList();
  }

  // ---------------- Seed Data ----------------

  void _seedFavorites() {
    _favoriteRecipeIds.addAll([
      'bf_001', 'bf_005', 'ln_001', 'ln_007', 'dn_001', 'dn_008',
    ]);
  }

  void _seedMockMealPlan() {
    final today = DateTime.now();
    final startOfWeek = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    // Build 7 daily plans with curated recipes
    final dailyPlans = <DailyMealPlan>[];
    final weekRecipes = <List<String>>[
      // Each row: [breakfastId, lunchId, dinnerId, snackId]
      ['bf_001', 'ln_001', 'dn_001', 'sn_001'],
      ['bf_004', 'ln_004', 'dn_004', 'sn_005'],
      ['bf_007', 'ln_007', 'dn_008', 'sn_009'],
      ['bf_011', 'ln_015', 'dn_012', 'sn_011'],
      ['bf_006', 'ln_019', 'dn_023', 'sn_013'],
      ['bf_002', 'ln_022', 'dn_032', 'sn_017'],
      ['bf_020', 'ln_037', 'dn_051', 'sn_021'],
    ];

    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final ids = weekRecipes[i];
      final meals = <PlannedMeal>[];
      final mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
      for (int m = 0; m < 4; m++) {
        final recipe = getRecipeById(ids[m]);
        if (recipe == null) continue;
        meals.add(PlannedMeal(
          id: 'pm_seed_${i}_$m',
          mealType: mealTypes[m],
          recipeId: recipe.id,
          recipeName: recipe.name,
          servings: 1,
          calories: recipe.caloriesPerServing,
          protein: recipe.proteinPerServing.round(),
          carbs: recipe.carbsPerServing.round(),
          fat: recipe.fatPerServing.round(),
          prepTime: recipe.totalTimeMinutes,
        ));
      }
      dailyPlans.add(DailyMealPlan.fromMeals(date: date, meals: meals));
    }

    final plan = MealPlan(
      id: 'mp_seed_1',
      userId: 'user_1',
      name: 'High Protein Week 1',
      startDate: startOfWeek,
      endDate: endOfWeek,
      goal: 'build_muscle',
      targetCalories: 2400,
      targetProtein: 180,
      targetCarbs: 260,
      targetFat: 75,
      restrictions: const [],
      days: dailyPlans,
      isAiGenerated: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    _mealPlans[plan.id] = plan;
  }
}

final mealPlanRepositoryProvider =
    Provider<MealPlanRepository>((ref) => MealPlanRepository());
