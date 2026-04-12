class GroceryItem {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final String category; // produce, meat, dairy, pantry, frozen, bakery, beverages
  final bool isChecked;
  final double estimatedPrice;
  final String? notes;

  const GroceryItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.unit,
    required this.category,
    this.isChecked = false,
    this.estimatedPrice = 0.0,
    this.notes,
  });

  GroceryItem copyWith({
    String? id,
    String? name,
    double? amount,
    String? unit,
    String? category,
    bool? isChecked,
    double? estimatedPrice,
    String? notes,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      notes: notes ?? this.notes,
    );
  }

  factory GroceryItem.fromJson(Map<String, dynamic> json) {
    return GroceryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
      category: json['category'] as String,
      isChecked: json['isChecked'] as bool? ?? false,
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'unit': unit,
        'category': category,
        'isChecked': isChecked,
        'estimatedPrice': estimatedPrice,
        'notes': notes,
      };
}

class GroceryList {
  final String id;
  final String userId;
  final String name;
  final String? mealPlanId;
  final DateTime createdAt;
  final List<GroceryItem> items;
  final double estimatedCost;
  final bool isCompleted;

  const GroceryList({
    required this.id,
    required this.userId,
    required this.name,
    this.mealPlanId,
    required this.createdAt,
    required this.items,
    required this.estimatedCost,
    this.isCompleted = false,
  });

  GroceryList copyWith({
    String? id,
    String? userId,
    String? name,
    String? mealPlanId,
    DateTime? createdAt,
    List<GroceryItem>? items,
    double? estimatedCost,
    bool? isCompleted,
  }) {
    return GroceryList(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory GroceryList.fromJson(Map<String, dynamic> json) {
    return GroceryList(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      mealPlanId: json['mealPlanId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List)
          .map((e) => GroceryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      estimatedCost: (json['estimatedCost'] as num).toDouble(),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'mealPlanId': mealPlanId,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'estimatedCost': estimatedCost,
        'isCompleted': isCompleted,
      };

  Map<String, List<GroceryItem>> get itemsByCategory {
    final map = <String, List<GroceryItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    // Sort categories in typical shopping order
    const order = [
      'produce',
      'meat',
      'dairy',
      'bakery',
      'pantry',
      'frozen',
      'beverages',
      'other',
    ];
    final sortedEntries = map.entries.toList()
      ..sort((a, b) {
        final aIdx = order.indexOf(a.key);
        final bIdx = order.indexOf(b.key);
        final aVal = aIdx == -1 ? 999 : aIdx;
        final bVal = bIdx == -1 ? 999 : bIdx;
        return aVal.compareTo(bVal);
      });
    return {for (final e in sortedEntries) e.key: e.value};
  }

  int get checkedCount => items.where((i) => i.isChecked).length;

  double get completionPercent =>
      items.isEmpty ? 0.0 : checkedCount / items.length;
}
