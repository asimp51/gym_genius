enum DietaryRestriction {
  vegetarian,
  vegan,
  glutenFree,
  dairyFree,
  nutFree,
  lowCarb,
  keto,
  paleo,
  halal,
  kosher;

  String get displayName {
    switch (this) {
      case DietaryRestriction.vegetarian:
        return 'Vegetarian';
      case DietaryRestriction.vegan:
        return 'Vegan';
      case DietaryRestriction.glutenFree:
        return 'Gluten-Free';
      case DietaryRestriction.dairyFree:
        return 'Dairy-Free';
      case DietaryRestriction.nutFree:
        return 'Nut-Free';
      case DietaryRestriction.lowCarb:
        return 'Low-Carb';
      case DietaryRestriction.keto:
        return 'Keto';
      case DietaryRestriction.paleo:
        return 'Paleo';
      case DietaryRestriction.halal:
        return 'Halal';
      case DietaryRestriction.kosher:
        return 'Kosher';
    }
  }

  String get tag {
    switch (this) {
      case DietaryRestriction.vegetarian:
        return 'vegetarian';
      case DietaryRestriction.vegan:
        return 'vegan';
      case DietaryRestriction.glutenFree:
        return 'gluten_free';
      case DietaryRestriction.dairyFree:
        return 'dairy_free';
      case DietaryRestriction.nutFree:
        return 'nut_free';
      case DietaryRestriction.lowCarb:
        return 'low_carb';
      case DietaryRestriction.keto:
        return 'keto';
      case DietaryRestriction.paleo:
        return 'paleo';
      case DietaryRestriction.halal:
        return 'halal';
      case DietaryRestriction.kosher:
        return 'kosher';
    }
  }

  static DietaryRestriction? fromTag(String tag) {
    for (final r in DietaryRestriction.values) {
      if (r.tag == tag || r.name == tag) return r;
    }
    return null;
  }
}

class PlannedMeal {
  final String id;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack', 'pre_workout', 'post_workout'
  final String recipeId;
  final String recipeName;
  final int servings;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final int prepTime; // minutes
  final bool isCompleted;

  const PlannedMeal({
    required this.id,
    required this.mealType,
    required this.recipeId,
    required this.recipeName,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.prepTime,
    this.isCompleted = false,
  });

  PlannedMeal copyWith({
    String? id,
    String? mealType,
    String? recipeId,
    String? recipeName,
    int? servings,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    int? prepTime,
    bool? isCompleted,
  }) {
    return PlannedMeal(
      id: id ?? this.id,
      mealType: mealType ?? this.mealType,
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      prepTime: prepTime ?? this.prepTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory PlannedMeal.fromJson(Map<String, dynamic> json) {
    return PlannedMeal(
      id: json['id'] as String,
      mealType: json['mealType'] as String,
      recipeId: json['recipeId'] as String,
      recipeName: json['recipeName'] as String,
      servings: json['servings'] as int,
      calories: json['calories'] as int,
      protein: json['protein'] as int,
      carbs: json['carbs'] as int,
      fat: json['fat'] as int,
      prepTime: json['prepTime'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mealType': mealType,
        'recipeId': recipeId,
        'recipeName': recipeName,
        'servings': servings,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'prepTime': prepTime,
        'isCompleted': isCompleted,
      };
}

class DailyMealPlan {
  final DateTime date;
  final List<PlannedMeal> meals;
  final int totalCalories;
  final int totalProtein;
  final int totalCarbs;
  final int totalFat;

  const DailyMealPlan({
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  DailyMealPlan copyWith({
    DateTime? date,
    List<PlannedMeal>? meals,
    int? totalCalories,
    int? totalProtein,
    int? totalCarbs,
    int? totalFat,
  }) {
    return DailyMealPlan(
      date: date ?? this.date,
      meals: meals ?? this.meals,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
    );
  }

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    return DailyMealPlan(
      date: DateTime.parse(json['date'] as String),
      meals: (json['meals'] as List)
          .map((e) => PlannedMeal.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCalories: json['totalCalories'] as int,
      totalProtein: json['totalProtein'] as int,
      totalCarbs: json['totalCarbs'] as int,
      totalFat: json['totalFat'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'meals': meals.map((e) => e.toJson()).toList(),
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
      };

  factory DailyMealPlan.fromMeals({
    required DateTime date,
    required List<PlannedMeal> meals,
  }) {
    int cal = 0, pro = 0, carb = 0, fat = 0;
    for (final m in meals) {
      cal += m.calories * m.servings;
      pro += m.protein * m.servings;
      carb += m.carbs * m.servings;
      fat += m.fat * m.servings;
    }
    return DailyMealPlan(
      date: date,
      meals: meals,
      totalCalories: cal,
      totalProtein: pro,
      totalCarbs: carb,
      totalFat: fat,
    );
  }
}

class MealPlan {
  final String id;
  final String userId;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String goal; // 'build_muscle', 'lose_weight', 'maintain', 'cut', 'bulk'
  final int targetCalories;
  final int targetProtein;
  final int targetCarbs;
  final int targetFat;
  final List<DietaryRestriction> restrictions;
  final List<DailyMealPlan> days;
  final bool isAiGenerated;
  final DateTime createdAt;

  const MealPlan({
    required this.id,
    required this.userId,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.goal,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.restrictions,
    required this.days,
    required this.isAiGenerated,
    required this.createdAt,
  });

  MealPlan copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    String? goal,
    int? targetCalories,
    int? targetProtein,
    int? targetCarbs,
    int? targetFat,
    List<DietaryRestriction>? restrictions,
    List<DailyMealPlan>? days,
    bool? isAiGenerated,
    DateTime? createdAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goal: goal ?? this.goal,
      targetCalories: targetCalories ?? this.targetCalories,
      targetProtein: targetProtein ?? this.targetProtein,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      targetFat: targetFat ?? this.targetFat,
      restrictions: restrictions ?? this.restrictions,
      days: days ?? this.days,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      goal: json['goal'] as String,
      targetCalories: json['targetCalories'] as int,
      targetProtein: json['targetProtein'] as int,
      targetCarbs: json['targetCarbs'] as int,
      targetFat: json['targetFat'] as int,
      restrictions: (json['restrictions'] as List)
          .map((e) => DietaryRestriction.fromTag(e as String))
          .whereType<DietaryRestriction>()
          .toList(),
      days: (json['days'] as List)
          .map((e) => DailyMealPlan.fromJson(e as Map<String, dynamic>))
          .toList(),
      isAiGenerated: json['isAiGenerated'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'goal': goal,
        'targetCalories': targetCalories,
        'targetProtein': targetProtein,
        'targetCarbs': targetCarbs,
        'targetFat': targetFat,
        'restrictions': restrictions.map((e) => e.tag).toList(),
        'days': days.map((e) => e.toJson()).toList(),
        'isAiGenerated': isAiGenerated,
        'createdAt': createdAt.toIso8601String(),
      };

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate.subtract(const Duration(days: 1))) &&
        now.isBefore(endDate.add(const Duration(days: 1)));
  }

  DailyMealPlan? dayFor(DateTime date) {
    for (final d in days) {
      if (d.date.year == date.year &&
          d.date.month == date.month &&
          d.date.day == date.day) {
        return d;
      }
    }
    return null;
  }
}
