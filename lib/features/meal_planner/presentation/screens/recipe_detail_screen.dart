import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_genius/config/theme/app_colors.dart';
import 'package:gym_genius/config/theme/app_typography.dart';
import 'package:gym_genius/config/theme/app_dimensions.dart';
import 'package:gym_genius/core/widgets/app_button.dart';
import 'package:gym_genius/features/meal_planner/domain/recipe_model.dart';
import 'package:gym_genius/features/meal_planner/presentation/providers/meal_planner_providers.dart';
import 'package:gym_genius/features/meal_planner/presentation/providers/grocery_providers.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() =>
      _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<int> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = ref.watch(recipeByIdProvider(widget.recipeId));

    if (recipe == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.bgPrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text('Recipe not found', style: AppTypography.body),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: AppColors.bgPrimary,
                    elevation: 0,
                    pinned: true,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => context.pop(),
                    ),
                    title: Text(recipe.name,
                        style: AppTypography.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.share_outlined,
                            color: AppColors.text2),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Share recipe')),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          recipe.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipe.isFavorite
                              ? AppColors.error
                              : AppColors.text2,
                        ),
                        onPressed: () {
                          ref
                              .read(mealPlanRepositoryProvider)
                              .toggleFavorite(recipe.id);
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero image
                        Container(
                          height: 220,
                          margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          decoration: BoxDecoration(
                            gradient: _gradientFor(recipe.id),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusCard),
                          ),
                          child: Center(
                            child: Text(
                              _foodEmoji(recipe.mealType),
                              style: const TextStyle(fontSize: 96),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(recipe.name, style: AppTypography.h1),
                              const SizedBox(height: 6),
                              Text(
                                recipe.description,
                                style: AppTypography.caption,
                              ),
                              const SizedBox(height: 16),
                              // Meta row
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: [
                                  _MetaChip(
                                    icon: Icons.timer_outlined,
                                    label: '${recipe.totalTimeMinutes} min',
                                  ),
                                  _MetaChip(
                                    icon: Icons.local_fire_department,
                                    label: '${recipe.caloriesPerServing} cal',
                                  ),
                                  _MetaChip(
                                    icon: Icons.star,
                                    label: recipe.rating.toStringAsFixed(1),
                                    color: AppColors.warning,
                                  ),
                                  _MetaChip(
                                    icon: Icons.people_outline,
                                    label: '${recipe.servings} servings',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Macros
                              Container(
                                padding: const EdgeInsets.all(
                                    AppDimensions.paddingLG),
                                decoration: BoxDecoration(
                                  color: AppColors.bgSecondary,
                                  borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusCard),
                                  border:
                                      Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    _MacroCell(
                                      label: 'Protein',
                                      value: recipe.proteinPerServing,
                                      color: AppColors.error,
                                    ),
                                    _MacroCell(
                                      label: 'Carbs',
                                      value: recipe.carbsPerServing,
                                      color: AppColors.warning,
                                    ),
                                    _MacroCell(
                                      label: 'Fat',
                                      value: recipe.fatPerServing,
                                      color: AppColors.success,
                                    ),
                                    _MacroCell(
                                      label: 'Fiber',
                                      value: recipe.fiberPerServing,
                                      color: AppColors.accent,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              TabBar(
                                controller: _tabController,
                                indicatorColor: AppColors.accent,
                                labelColor: AppColors.accent,
                                unselectedLabelColor: AppColors.text3,
                                labelStyle: AppTypography.button,
                                tabs: const [
                                  Tab(text: 'Ingredients'),
                                  Tab(text: 'Instructions'),
                                  Tab(text: 'Tips'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 500,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _IngredientsTab(
                                ingredients: recipe.ingredients,
                                checked: _checkedIngredients,
                                onToggle: (i) => setState(() {
                                  if (_checkedIngredients.contains(i)) {
                                    _checkedIngredients.remove(i);
                                  } else {
                                    _checkedIngredients.add(i);
                                  }
                                }),
                              ),
                              _InstructionsTab(
                                  instructions: recipe.instructions),
                              _TipsTab(tips: recipe.tips),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: const BoxDecoration(
                color: AppColors.bgPrimary,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'To Grocery',
                      icon: Icons.shopping_cart_outlined,
                      onPressed: () {
                        ref
                            .read(groceryRepositoryProvider)
                            .addRecipeToList(recipe);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Added ${recipe.name} to grocery list')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: 'Add to Plan',
                      icon: Icons.add_circle_outline,
                      onPressed: () => _showAddToPlanSheet(context, recipe),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddToPlanSheet(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add to meal plan', style: AppTypography.h2),
            const SizedBox(height: 16),
            ...['breakfast', 'lunch', 'dinner', 'snack'].map(
              (type) => ListTile(
                leading: const Icon(Icons.restaurant,
                    color: AppColors.accent),
                title: Text(
                  type[0].toUpperCase() + type.substring(1),
                  style: AppTypography.body,
                ),
                onTap: () {
                  ref
                      .read(mealPlanRepositoryProvider)
                      .addRecipeToPlan(recipe.id, type, DateTime.now());
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added to $type')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _gradientFor(String id) {
    final palettes = [
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
      [const Color(0xFF10B981), const Color(0xFF22D3EE)],
      [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
      [const Color(0xFF3B82F6), const Color(0xFF22D3EE)],
    ];
    final idx = id.hashCode.abs() % palettes.length;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: palettes[idx],
    );
  }

  String _foodEmoji(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return '\ud83e\udd5e';
      case 'lunch':
        return '\ud83e\udd57';
      case 'dinner':
        return '\ud83c\udf5d';
      case 'snack':
        return '\ud83e\udd66';
      default:
        return '\ud83c\udf72';
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? AppColors.text2),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _MacroCell extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MacroCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 4),
          Text(
            '${value.toInt()}g',
            style: AppTypography.stat.copyWith(color: color, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _IngredientsTab extends StatelessWidget {
  final List<Ingredient> ingredients;
  final Set<int> checked;
  final ValueChanged<int> onToggle;

  const _IngredientsTab({
    required this.ingredients,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: ingredients.length,
      itemBuilder: (context, i) {
        final ing = ingredients[i];
        final isChecked = checked.contains(i);
        return InkWell(
          onTap: () => onToggle(i),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppColors.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked
                          ? AppColors.accent
                          : AppColors.text3,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check,
                          size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ing.name,
                    style: AppTypography.body.copyWith(
                      color: isChecked ? AppColors.text3 : AppColors.text1,
                      decoration:
                          isChecked ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Text(
                  '${_fmt(ing.amount)} ${ing.unit}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

class _InstructionsTab extends StatelessWidget {
  final List<String> instructions;
  const _InstructionsTab({required this.instructions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: instructions.length,
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    instructions[i],
                    style: AppTypography.body,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TipsTab extends StatelessWidget {
  final List<String> tips;
  const _TipsTab({required this.tips});

  @override
  Widget build(BuildContext context) {
    final fallbackTips = tips.isEmpty
        ? [
            'Use fresh ingredients for the best flavor.',
            'Prep ingredients before cooking for a smoother process.',
            'Adjust seasonings to taste.',
          ]
        : tips;

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: fallbackTips.length,
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(AppDimensions.paddingLG),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: const Border(
              left: BorderSide(color: AppColors.warning, width: 3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('\ud83d\udca1', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(fallbackTips[i], style: AppTypography.body),
              ),
            ],
          ),
        );
      },
    );
  }
}
