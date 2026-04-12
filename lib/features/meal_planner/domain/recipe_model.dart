class Ingredient {
  final String name;
  final double amount;
  final String unit; // 'g', 'oz', 'cup', 'tbsp', 'tsp', 'ml', 'piece'
  final String? category; // 'produce', 'meat', 'dairy', 'pantry', 'frozen', 'bakery', 'beverages'
  final bool isOptional;

  const Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.category,
    this.isOptional = false,
  });

  Ingredient copyWith({
    String? name,
    double? amount,
    String? unit,
    String? category,
    bool? isOptional,
  }) {
    return Ingredient(
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isOptional: isOptional ?? this.isOptional,
    );
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      category: json['category'] as String?,
      isOptional: json['isOptional'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'amount': amount,
        'unit': unit,
        'category': category,
        'isOptional': isOptional,
      };
}

class Recipe {
  final String id;
  final String name;
  final String description;
  final String mealType; // breakfast, lunch, dinner, snack, pre_workout, post_workout
  final List<String> categories; // 'high_protein', 'low_carb', 'quick', 'meal_prep', 'budget', etc
  final List<String> dietaryTags; // 'vegetarian', 'vegan', 'gluten_free', etc
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final String difficulty; // 'easy', 'medium', 'hard'

  // Per serving nutrition
  final int caloriesPerServing;
  final double proteinPerServing;
  final double carbsPerServing;
  final double fatPerServing;
  final double fiberPerServing;

  final List<Ingredient> ingredients;
  final List<String> instructions;
  final List<String> equipmentNeeded;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> tips;
  final bool isFavorite;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.mealType,
    required this.categories,
    required this.dietaryTags,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.caloriesPerServing,
    required this.proteinPerServing,
    required this.carbsPerServing,
    required this.fatPerServing,
    required this.fiberPerServing,
    required this.ingredients,
    required this.instructions,
    required this.equipmentNeeded,
    this.imageUrl,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.tips = const [],
    this.isFavorite = false,
  });

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    String? mealType,
    List<String>? categories,
    List<String>? dietaryTags,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    String? difficulty,
    int? caloriesPerServing,
    double? proteinPerServing,
    double? carbsPerServing,
    double? fatPerServing,
    double? fiberPerServing,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    List<String>? equipmentNeeded,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    List<String>? tips,
    bool? isFavorite,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mealType: mealType ?? this.mealType,
      categories: categories ?? this.categories,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      caloriesPerServing: caloriesPerServing ?? this.caloriesPerServing,
      proteinPerServing: proteinPerServing ?? this.proteinPerServing,
      carbsPerServing: carbsPerServing ?? this.carbsPerServing,
      fatPerServing: fatPerServing ?? this.fatPerServing,
      fiberPerServing: fiberPerServing ?? this.fiberPerServing,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      equipmentNeeded: equipmentNeeded ?? this.equipmentNeeded,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      tips: tips ?? this.tips,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      mealType: json['mealType'] as String,
      categories:
          (json['categories'] as List).map((e) => e as String).toList(),
      dietaryTags:
          (json['dietaryTags'] as List).map((e) => e as String).toList(),
      prepTimeMinutes: json['prepTimeMinutes'] as int,
      cookTimeMinutes: json['cookTimeMinutes'] as int,
      servings: json['servings'] as int,
      difficulty: json['difficulty'] as String,
      caloriesPerServing: json['caloriesPerServing'] as int,
      proteinPerServing: (json['proteinPerServing'] as num).toDouble(),
      carbsPerServing: (json['carbsPerServing'] as num).toDouble(),
      fatPerServing: (json['fatPerServing'] as num).toDouble(),
      fiberPerServing: (json['fiberPerServing'] as num).toDouble(),
      ingredients: (json['ingredients'] as List)
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      instructions:
          (json['instructions'] as List).map((e) => e as String).toList(),
      equipmentNeeded:
          (json['equipmentNeeded'] as List).map((e) => e as String).toList(),
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: json['reviewCount'] as int? ?? 0,
      tips: (json['tips'] as List?)?.map((e) => e as String).toList() ?? const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'mealType': mealType,
        'categories': categories,
        'dietaryTags': dietaryTags,
        'prepTimeMinutes': prepTimeMinutes,
        'cookTimeMinutes': cookTimeMinutes,
        'servings': servings,
        'difficulty': difficulty,
        'caloriesPerServing': caloriesPerServing,
        'proteinPerServing': proteinPerServing,
        'carbsPerServing': carbsPerServing,
        'fatPerServing': fatPerServing,
        'fiberPerServing': fiberPerServing,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'instructions': instructions,
        'equipmentNeeded': equipmentNeeded,
        'imageUrl': imageUrl,
        'rating': rating,
        'reviewCount': reviewCount,
        'tips': tips,
        'isFavorite': isFavorite,
      };
}
