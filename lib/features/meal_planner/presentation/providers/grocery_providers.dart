import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_genius/features/meal_planner/data/grocery_repository.dart';
import 'package:gym_genius/features/meal_planner/domain/grocery_list_model.dart';

// Re-export so screens can get groceryRepositoryProvider from this file
export 'package:gym_genius/features/meal_planner/data/grocery_repository.dart'
    show groceryRepositoryProvider;

/// The currently active grocery list.
final activeGroceryListProvider = Provider<GroceryList?>((ref) {
  final repo = ref.watch(groceryRepositoryProvider);
  return repo.getActiveList();
});
