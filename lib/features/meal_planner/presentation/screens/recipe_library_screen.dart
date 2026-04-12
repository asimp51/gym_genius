import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_genius/config/theme/app_colors.dart';
import 'package:gym_genius/config/theme/app_typography.dart';
import 'package:gym_genius/config/theme/app_dimensions.dart';
import 'package:gym_genius/core/widgets/app_text_field.dart';
import 'package:gym_genius/features/meal_planner/domain/recipe_model.dart';
import 'package:gym_genius/features/meal_planner/presentation/providers/meal_planner_providers.dart';
import 'package:gym_genius/core/widgets/ad_banner_widget.dart';
import 'package:gym_genius/services/ad_service.dart';

class RecipeLibraryScreen extends ConsumerStatefulWidget {
  const RecipeLibraryScreen({super.key});

  @override
  ConsumerState<RecipeLibraryScreen> createState() =>
      _RecipeLibraryScreenState();
}

class _RecipeLibraryScreenState extends ConsumerState<RecipeLibraryScreen> {
  final _controller = TextEditingController();

  static const _mealTypes = [
    ('all', 'All'),
    ('breakfast', 'Breakfast'),
    ('lunch', 'Lunch'),
    ('dinner', 'Dinner'),
    ('snack', 'Snacks'),
  ];

  static const _dietFilters = [
    ('all', 'All'),
    ('high_protein', 'High Protein'),
    ('low_carb', 'Low Carb'),
    ('vegetarian', 'Vegetarian'),
    ('vegan', 'Vegan'),
    ('quick', 'Quick'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(filteredRecipesProvider);
    final selectedMealType = ref.watch(recipeMealTypeFilterProvider);
    final selectedDiet = ref.watch(recipeDietFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Recipes', style: AppTypography.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.text2),
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppDimensions.padding2XL, 12, AppDimensions.padding2XL, 12),
              child: AppTextField(
                controller: _controller,
                hint: 'Search recipes...',
                prefixIcon: Icons.search,
                onChanged: (v) {
                  ref.read(recipeSearchQueryProvider.notifier).state = v;
                },
              ),
            ),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _mealTypes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final (val, label) = _mealTypes[i];
                  final selected = selectedMealType == val;
                  return _FilterChip(
                    label: label,
                    selected: selected,
                    onTap: () => ref
                        .read(recipeMealTypeFilterProvider.notifier)
                        .state = val,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _dietFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final (val, label) = _dietFilters[i];
                  final selected = selectedDiet == val;
                  return _FilterChip(
                    label: label,
                    selected: selected,
                    onTap: () => ref
                        .read(recipeDietFilterProvider.notifier)
                        .state = val,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Ad banner for free tier users
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: AdBannerWidget(placement: AdPlacement.recipeBanner),
            ),
            Expanded(
              child: recipes.isEmpty
                  ? _EmptyRecipes()
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.padding2XL,
                        0,
                        AppDimensions.padding2XL,
                        AppDimensions.padding2XL,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = recipes[index];
                        return _RecipeCard(
                          recipe: recipe,
                          onTap: () =>
                              context.push('/recipe-detail/${recipe.id}'),
                          onFavorite: () {
                            ref
                                .read(mealPlanRepositoryProvider)
                                .toggleFavorite(recipe.id);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.gradient : null,
          color: selected ? null : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: selected ? Colors.white : AppColors.text2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const _RecipeCard({
    required this.recipe,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: _gradientFor(recipe.id),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.radiusCard),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _foodEmoji(recipe.mealType),
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          recipe.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: recipe.isFavorite
                              ? AppColors.error
                              : Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            size: 12, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text('${recipe.caloriesPerServing}',
                            style: AppTypography.caption
                                .copyWith(fontSize: 11)),
                        const SizedBox(width: 8),
                        Icon(Icons.timer_outlined,
                            size: 12, color: AppColors.text3),
                        const SizedBox(width: 2),
                        Text('${recipe.totalTimeMinutes}m',
                            style: AppTypography.caption
                                .copyWith(fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'P: ${recipe.proteinPerServing.toInt()}g',
                      style: AppTypography.caption.copyWith(
                          fontSize: 11, color: AppColors.accent),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 12, color: AppColors.warning),
                        const SizedBox(width: 2),
                        Text(
                          recipe.rating.toStringAsFixed(1),
                          style:
                              AppTypography.caption.copyWith(fontSize: 11),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${recipe.reviewCount})',
                          style: AppTypography.caption
                              .copyWith(fontSize: 10, color: AppColors.text3),
                        ),
                      ],
                    ),
                  ],
                ),
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

class _EmptyRecipes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\ud83d\udd0d', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text('No recipes found', style: AppTypography.h3),
            const SizedBox(height: 4),
            Text(
              'Try adjusting your filters',
              style: AppTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}
