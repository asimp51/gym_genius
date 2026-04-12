import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/nutrition_model.dart';

class NutritionRepository {
  final Map<String, NutritionLog> _logs = {};

  NutritionRepository() {
    _seedMockData();
  }

  NutritionLog getLogForDate(String userId, DateTime date) {
    final key = _dateKey(date);
    return _logs[key] ?? NutritionLog(
      id: 'log_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      date: date,
      meals: const [],
      totals: const NutritionTotals(calories: 0, protein: 0, carbs: 0, fat: 0),
      goals: const NutritionTotals(calories: 2200, protein: 160, carbs: 250, fat: 70),
    );
  }

  void saveLog(NutritionLog log) {
    final key = _dateKey(log.date);
    _logs[key] = log;
  }

  NutritionLog addFoodToMeal(String userId, DateTime date, String mealName, FoodItem food) {
    final log = getLogForDate(userId, date);
    final meals = List<Meal>.from(log.meals);

    final mealIndex = meals.indexWhere((m) => m.name == mealName);
    if (mealIndex >= 0) {
      final foods = List<FoodItem>.from(meals[mealIndex].foods)..add(food);
      meals[mealIndex] = meals[mealIndex].copyWith(foods: foods);
    } else {
      meals.add(Meal(name: mealName, foods: [food]));
    }

    final totals = _calculateTotals(meals);
    final updated = log.copyWith(meals: meals, totals: totals);
    saveLog(updated);
    return updated;
  }

  NutritionLog removeFoodFromMeal(String userId, DateTime date, String mealName, int foodIndex) {
    final log = getLogForDate(userId, date);
    final meals = List<Meal>.from(log.meals);

    final mealIndex = meals.indexWhere((m) => m.name == mealName);
    if (mealIndex >= 0) {
      final foods = List<FoodItem>.from(meals[mealIndex].foods);
      if (foodIndex < foods.length) {
        foods.removeAt(foodIndex);
        meals[mealIndex] = meals[mealIndex].copyWith(foods: foods);
      }
    }

    final totals = _calculateTotals(meals);
    final updated = log.copyWith(meals: meals, totals: totals);
    saveLog(updated);
    return updated;
  }

  void updateGoals(String userId, NutritionTotals goals) {
    for (final key in _logs.keys) {
      _logs[key] = _logs[key]!.copyWith(goals: goals);
    }
  }

  List<FoodItem> searchFoods(String query) {
    final q = query.toLowerCase();
    return _commonFoods.where((f) => f.name.toLowerCase().contains(q)).toList();
  }

  NutritionTotals _calculateTotals(List<Meal> meals) {
    double cal = 0, pro = 0, carb = 0, fat = 0;
    for (final meal in meals) {
      for (final food in meal.foods) {
        cal += food.calories * food.servings;
        pro += food.protein * food.servings;
        carb += food.carbs * food.servings;
        fat += food.fat * food.servings;
      }
    }
    return NutritionTotals(calories: cal, protein: pro, carbs: carb, fat: fat);
  }

  String _dateKey(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static final List<FoodItem> _commonFoods = [
    const FoodItem(name: 'Chicken Breast (grilled)', calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: '100g', servings: 1),
    const FoodItem(name: 'Brown Rice', calories: 216, protein: 5, carbs: 45, fat: 1.8, servingSize: '1 cup', servings: 1),
    const FoodItem(name: 'Eggs (whole)', calories: 155, protein: 13, carbs: 1.1, fat: 11, servingSize: '2 large', servings: 1),
    const FoodItem(name: 'Greek Yogurt', calories: 100, protein: 17, carbs: 6, fat: 0.7, servingSize: '170g', servings: 1),
    const FoodItem(name: 'Oatmeal', calories: 154, protein: 5, carbs: 27, fat: 2.6, servingSize: '1 cup', servings: 1),
    const FoodItem(name: 'Banana', calories: 105, protein: 1.3, carbs: 27, fat: 0.4, servingSize: '1 medium', servings: 1),
    const FoodItem(name: 'Salmon Fillet', calories: 208, protein: 20, carbs: 0, fat: 13, servingSize: '100g', servings: 1),
    const FoodItem(name: 'Sweet Potato', calories: 103, protein: 2.3, carbs: 24, fat: 0.1, servingSize: '1 medium', servings: 1),
    const FoodItem(name: 'Whey Protein Shake', calories: 120, protein: 24, carbs: 3, fat: 1.5, servingSize: '1 scoop', servings: 1),
    const FoodItem(name: 'Almonds', calories: 164, protein: 6, carbs: 6, fat: 14, servingSize: '28g', servings: 1),
    const FoodItem(name: 'Broccoli', calories: 55, protein: 3.7, carbs: 11, fat: 0.6, servingSize: '1 cup', servings: 1),
    const FoodItem(name: 'Avocado', calories: 240, protein: 3, carbs: 12, fat: 22, servingSize: '1 whole', servings: 1),
    const FoodItem(name: 'Steak (sirloin)', calories: 271, protein: 26, carbs: 0, fat: 18, servingSize: '170g', servings: 1),
    const FoodItem(name: 'Pasta (cooked)', calories: 220, protein: 8, carbs: 43, fat: 1.3, servingSize: '1 cup', servings: 1),
    const FoodItem(name: 'Tuna (canned)', calories: 132, protein: 29, carbs: 0, fat: 1, servingSize: '1 can', servings: 1),
    const FoodItem(name: 'Whole Wheat Bread', calories: 128, protein: 4, carbs: 24, fat: 2, servingSize: '2 slices', servings: 1),
    const FoodItem(name: 'Cottage Cheese', calories: 98, protein: 11, carbs: 3.4, fat: 4.3, servingSize: '100g', servings: 1),
    const FoodItem(name: 'Apple', calories: 95, protein: 0.5, carbs: 25, fat: 0.3, servingSize: '1 medium', servings: 1),
    const FoodItem(name: 'Peanut Butter', calories: 188, protein: 7, carbs: 6, fat: 16, servingSize: '2 tbsp', servings: 1),
    const FoodItem(name: 'Milk (whole)', calories: 149, protein: 8, carbs: 12, fat: 8, servingSize: '1 cup', servings: 1),
  ];

  void _seedMockData() {
    final today = DateTime.now();
    final key = _dateKey(today);

    _logs[key] = NutritionLog(
      id: 'log_today',
      userId: 'user_1',
      date: today,
      meals: const [
        Meal(name: 'Breakfast', foods: [
          FoodItem(name: 'Oatmeal', calories: 154, protein: 5, carbs: 27, fat: 2.6, servingSize: '1 cup', servings: 1),
          FoodItem(name: 'Banana', calories: 105, protein: 1.3, carbs: 27, fat: 0.4, servingSize: '1 medium', servings: 1),
          FoodItem(name: 'Whey Protein Shake', calories: 120, protein: 24, carbs: 3, fat: 1.5, servingSize: '1 scoop', servings: 1),
        ]),
        Meal(name: 'Lunch', foods: [
          FoodItem(name: 'Chicken Breast (grilled)', calories: 165, protein: 31, carbs: 0, fat: 3.6, servingSize: '100g', servings: 1.5),
          FoodItem(name: 'Brown Rice', calories: 216, protein: 5, carbs: 45, fat: 1.8, servingSize: '1 cup', servings: 1),
          FoodItem(name: 'Broccoli', calories: 55, protein: 3.7, carbs: 11, fat: 0.6, servingSize: '1 cup', servings: 1),
        ]),
        Meal(name: 'Dinner', foods: [
          FoodItem(name: 'Salmon Fillet', calories: 208, protein: 20, carbs: 0, fat: 13, servingSize: '100g', servings: 1.5),
          FoodItem(name: 'Sweet Potato', calories: 103, protein: 2.3, carbs: 24, fat: 0.1, servingSize: '1 medium', servings: 1),
          FoodItem(name: 'Avocado', calories: 240, protein: 3, carbs: 12, fat: 22, servingSize: '1 whole', servings: 0.5),
        ]),
      ],
      totals: const NutritionTotals(calories: 1850, protein: 142, carbs: 210, fat: 58),
      goals: const NutritionTotals(calories: 2200, protein: 160, carbs: 250, fat: 70),
    );
  }
}

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) => NutritionRepository());
