import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/grocery_list_model.dart';
import '../domain/recipe_model.dart';
import '../domain/meal_plan_model.dart';
import 'meal_plan_repository.dart';

class GroceryRepository {
  final Map<String, GroceryList> _lists = {};
  String? _activeListId;
  final MealPlanRepository _mealPlanRepo;

  GroceryRepository(this._mealPlanRepo) {
    _seedMockList();
  }

  // ---- Queries ----

  GroceryList? getActiveList() {
    if (_activeListId != null && _lists.containsKey(_activeListId)) {
      return _lists[_activeListId];
    }
    if (_lists.isNotEmpty) return _lists.values.first;
    return null;
  }

  List<GroceryList> getLists(String userId) {
    return _lists.values.where((l) => l.userId == userId).toList();
  }

  // ---- Commands ----

  void toggleItem(String itemId, bool checked) {
    final list = getActiveList();
    if (list == null) return;
    final updatedItems = list.items.map((item) {
      if (item.id == itemId) return item.copyWith(isChecked: checked);
      return item;
    }).toList();
    _lists[list.id] = list.copyWith(items: updatedItems);
  }

  void addCustomItem(String name) {
    GroceryList? list = getActiveList();
    if (list == null) {
      list = GroceryList(
        id: 'gl_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_1',
        name: 'My Grocery List',
        createdAt: DateTime.now(),
        items: [],
        estimatedCost: 0,
      );
      _lists[list.id] = list;
      _activeListId = list.id;
    }
    final item = GroceryItem(
      id: 'gi_custom_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      amount: 1,
      unit: 'piece',
      category: 'other',
      estimatedPrice: 2.99,
    );
    final newItems = [...list.items, item];
    _lists[list.id] = list.copyWith(
      items: newItems,
      estimatedCost: _totalCost(newItems),
    );
  }

  void clearList() {
    final list = getActiveList();
    if (list == null) return;
    _lists.remove(list.id);
    _activeListId = null;
  }

  void addRecipeToList(Recipe recipe) {
    GroceryList? list = getActiveList();
    if (list == null) {
      list = GroceryList(
        id: 'gl_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_1',
        name: 'My Grocery List',
        createdAt: DateTime.now(),
        items: [],
        estimatedCost: 0,
      );
      _lists[list.id] = list;
      _activeListId = list.id;
    }
    final newItems = <GroceryItem>[...list.items];
    for (final ing in recipe.ingredients) {
      final existingIdx =
          newItems.indexWhere((i) => i.name.toLowerCase() == ing.name.toLowerCase());
      if (existingIdx >= 0) {
        final existing = newItems[existingIdx];
        newItems[existingIdx] = existing.copyWith(
          amount: existing.amount + ing.amount,
        );
      } else {
        newItems.add(GroceryItem(
          id: 'gi_${DateTime.now().microsecondsSinceEpoch}_${ing.name.hashCode}',
          name: ing.name,
          amount: ing.amount,
          unit: ing.unit,
          category: ing.category ?? 'other',
          estimatedPrice: _estimatePrice(ing),
        ));
      }
    }
    _lists[list.id] = list.copyWith(
      items: newItems,
      estimatedCost: _totalCost(newItems),
    );
  }

  GroceryList generateFromMealPlan(MealPlan plan) {
    final merged = <String, _MergedIngredient>{};

    for (final day in plan.days) {
      for (final meal in day.meals) {
        final recipe = _mealPlanRepo.getRecipeById(meal.recipeId);
        if (recipe == null) continue;
        for (final ing in recipe.ingredients) {
          final key = ing.name.toLowerCase();
          if (merged.containsKey(key)) {
            merged[key]!.amount += ing.amount * meal.servings;
          } else {
            merged[key] = _MergedIngredient(
              name: ing.name,
              amount: ing.amount * meal.servings,
              unit: ing.unit,
              category: ing.category ?? 'other',
            );
          }
        }
      }
    }

    final items = merged.values.toList().asMap().entries.map((e) {
      final m = e.value;
      return GroceryItem(
        id: 'gi_gen_${e.key}',
        name: m.name,
        amount: m.amount,
        unit: m.unit,
        category: m.category,
        estimatedPrice: _estimatePriceFromMerged(m),
      );
    }).toList();

    final list = GroceryList(
      id: 'gl_gen_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_1',
      name: 'Grocery List for ${plan.name}',
      mealPlanId: plan.id,
      createdAt: DateTime.now(),
      items: items,
      estimatedCost: _totalCost(items),
    );
    _lists[list.id] = list;
    _activeListId = list.id;
    return list;
  }

  void generateFromActivePlan() {
    final plan = _mealPlanRepo.getActiveMealPlan('user_1');
    if (plan == null) return;
    generateFromMealPlan(plan);
  }

  // ---- Helpers ----

  double _totalCost(List<GroceryItem> items) =>
      items.fold(0.0, (s, i) => s + i.estimatedPrice);

  double _estimatePrice(Ingredient ing) {
    switch (ing.category) {
      case 'meat':
        return 5.99;
      case 'produce':
        return 2.49;
      case 'dairy':
        return 3.49;
      case 'frozen':
        return 3.99;
      case 'bakery':
        return 3.29;
      case 'beverages':
        return 2.99;
      default:
        return 1.99;
    }
  }

  double _estimatePriceFromMerged(_MergedIngredient m) {
    switch (m.category) {
      case 'meat':
        return 5.99;
      case 'produce':
        return 2.49;
      case 'dairy':
        return 3.49;
      case 'frozen':
        return 3.99;
      case 'bakery':
        return 3.29;
      case 'beverages':
        return 2.99;
      default:
        return 1.99;
    }
  }

  void _seedMockList() {
    final items = [
      const GroceryItem(id: 'gi_1', name: 'Chicken breast', amount: 1000, unit: 'g', category: 'meat', estimatedPrice: 8.99),
      const GroceryItem(id: 'gi_2', name: 'Salmon fillet', amount: 500, unit: 'g', category: 'meat', estimatedPrice: 12.99),
      const GroceryItem(id: 'gi_3', name: 'Greek yogurt', amount: 500, unit: 'g', category: 'dairy', estimatedPrice: 4.49),
      const GroceryItem(id: 'gi_4', name: 'Eggs', amount: 12, unit: 'piece', category: 'dairy', estimatedPrice: 3.99),
      const GroceryItem(id: 'gi_5', name: 'Broccoli', amount: 2, unit: 'piece', category: 'produce', estimatedPrice: 2.99),
      const GroceryItem(id: 'gi_6', name: 'Sweet potatoes', amount: 4, unit: 'piece', category: 'produce', estimatedPrice: 3.49),
      const GroceryItem(id: 'gi_7', name: 'Brown rice', amount: 1000, unit: 'g', category: 'pantry', estimatedPrice: 3.29),
      const GroceryItem(id: 'gi_8', name: 'Rolled oats', amount: 500, unit: 'g', category: 'pantry', estimatedPrice: 2.99),
      const GroceryItem(id: 'gi_9', name: 'Olive oil', amount: 500, unit: 'ml', category: 'pantry', estimatedPrice: 6.49),
      const GroceryItem(id: 'gi_10', name: 'Avocados', amount: 4, unit: 'piece', category: 'produce', estimatedPrice: 5.99),
      const GroceryItem(id: 'gi_11', name: 'Spinach', amount: 200, unit: 'g', category: 'produce', estimatedPrice: 2.99),
      const GroceryItem(id: 'gi_12', name: 'Whole wheat bread', amount: 1, unit: 'piece', category: 'bakery', estimatedPrice: 3.49),
      const GroceryItem(id: 'gi_13', name: 'Almond butter', amount: 250, unit: 'g', category: 'pantry', estimatedPrice: 7.99),
      const GroceryItem(id: 'gi_14', name: 'Frozen berries', amount: 500, unit: 'g', category: 'frozen', estimatedPrice: 4.99),
      const GroceryItem(id: 'gi_15', name: 'Whey protein powder', amount: 500, unit: 'g', category: 'pantry', estimatedPrice: 24.99),
      const GroceryItem(id: 'gi_16', name: 'Banana', amount: 6, unit: 'piece', category: 'produce', estimatedPrice: 1.99),
      const GroceryItem(id: 'gi_17', name: 'Cheddar cheese', amount: 200, unit: 'g', category: 'dairy', estimatedPrice: 3.99),
      const GroceryItem(id: 'gi_18', name: 'Ground turkey', amount: 500, unit: 'g', category: 'meat', estimatedPrice: 6.49),
    ];

    final list = GroceryList(
      id: 'gl_seed_1',
      userId: 'user_1',
      name: 'Weekly Groceries',
      createdAt: DateTime.now(),
      items: items,
      estimatedCost: items.fold(0.0, (s, i) => s + i.estimatedPrice),
    );
    _lists[list.id] = list;
    _activeListId = list.id;
  }
}

class _MergedIngredient {
  final String name;
  double amount;
  final String unit;
  final String category;
  _MergedIngredient({
    required this.name,
    required this.amount,
    required this.unit,
    required this.category,
  });
}

final groceryRepositoryProvider = Provider<GroceryRepository>((ref) {
  final mealPlanRepo = ref.watch(mealPlanRepositoryProvider);
  return GroceryRepository(mealPlanRepo);
});
