class NutritionLog {
  final String id;
  final String userId;
  final DateTime date;
  final List<Meal> meals;
  final NutritionTotals totals;
  final NutritionTotals goals;

  const NutritionLog({
    required this.id,
    required this.userId,
    required this.date,
    required this.meals,
    required this.totals,
    required this.goals,
  });

  NutritionLog copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<Meal>? meals,
    NutritionTotals? totals,
    NutritionTotals? goals,
  }) {
    return NutritionLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      totals: totals ?? this.totals,
      goals: goals ?? this.goals,
    );
  }

  factory NutritionLog.fromJson(Map<String, dynamic> json) {
    return NutritionLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      meals: (json['meals'] as List)
          .map((e) => Meal.fromJson(e as Map<String, dynamic>))
          .toList(),
      totals:
          NutritionTotals.fromJson(json['totals'] as Map<String, dynamic>),
      goals: NutritionTotals.fromJson(json['goals'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'date': date.toIso8601String(),
        'meals': meals.map((e) => e.toJson()).toList(),
        'totals': totals.toJson(),
        'goals': goals.toJson(),
      };
}

class Meal {
  final String name; // Breakfast, Lunch, Dinner, Snack
  final List<FoodItem> foods;

  const Meal({
    required this.name,
    required this.foods,
  });

  Meal copyWith({
    String? name,
    List<FoodItem>? foods,
  }) {
    return Meal(
      name: name ?? this.name,
      foods: foods ?? this.foods,
    );
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] as String,
      foods: (json['foods'] as List)
          .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'foods': foods.map((e) => e.toJson()).toList(),
      };
}

class FoodItem {
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String servingSize;
  final double servings;
  final String? barcode;

  const FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    this.servings = 1.0,
    this.barcode,
  });

  FoodItem copyWith({
    String? name,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? servingSize,
    double? servings,
    String? barcode,
  }) {
    return FoodItem(
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      servingSize: servingSize ?? this.servingSize,
      servings: servings ?? this.servings,
      barcode: barcode ?? this.barcode,
    );
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      servingSize: json['servingSize'] as String,
      servings: (json['servings'] as num?)?.toDouble() ?? 1.0,
      barcode: json['barcode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'servingSize': servingSize,
        'servings': servings,
        'barcode': barcode,
      };
}

class NutritionTotals {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  NutritionTotals copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return NutritionTotals(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  factory NutritionTotals.fromJson(Map<String, dynamic> json) {
    return NutritionTotals(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory NutritionTotals.zero() => const NutritionTotals(
        calories: 0,
        protein: 0,
        carbs: 0,
        fat: 0,
      );
}
