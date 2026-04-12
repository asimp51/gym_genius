import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/nutrition_providers.dart';
import '../../../../core/widgets/ad_banner_widget.dart';
import '../../../../services/ad_service.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(nutritionLogProvider);
    final calProgress = ref.watch(calorieProgressProvider);
    final proteinProgress = ref.watch(proteinProgressProvider);
    final carbsProgress = ref.watch(carbsProgressProvider);
    final fatProgress = ref.watch(fatProgressProvider);
    final foodSearchResults = ref.watch(foodSearchResultsProvider);

    final totals = log.totals;
    final goals = log.goals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Date picker to change nutritionDateProvider
            },
            child: Text(
              '${log.date.month}/${log.date.day}',
              style: AppTypography.caption.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart Meal Planner banner
            GestureDetector(
              onTap: () => context.push('/meal-planner'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent.withValues(alpha: 0.25),
                      AppColors.accentSecondary.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.gradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('\u2728',
                            style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Try Smart Meal Planner',
                            style: AppTypography.body
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'AI plans, recipes & grocery lists',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward,
                        color: AppColors.accent, size: 20),
                  ],
                ),
              ),
            ),
            // Macro circles
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MacroCircle(
                    label: 'Calories',
                    current: totals.calories.toInt(),
                    target: goals.calories.toInt(),
                    color: AppColors.accent,
                    unit: 'kcal',
                    progress: calProgress,
                  ),
                  _MacroCircle(
                    label: 'Protein',
                    current: totals.protein.toInt(),
                    target: goals.protein.toInt(),
                    color: AppColors.error,
                    unit: 'g',
                    progress: proteinProgress,
                  ),
                  _MacroCircle(
                    label: 'Carbs',
                    current: totals.carbs.toInt(),
                    target: goals.carbs.toInt(),
                    color: AppColors.warning,
                    unit: 'g',
                    progress: carbsProgress,
                  ),
                  _MacroCircle(
                    label: 'Fat',
                    current: totals.fat.toInt(),
                    target: goals.fat.toInt(),
                    color: AppColors.success,
                    unit: 'g',
                    progress: fatProgress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Meal cards from log
            ...log.meals.map((meal) {
              final mealCals = meal.foods.fold<double>(
                  0, (s, f) => s + f.calories);
              final mealEmoji = _mealEmoji(meal.name);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MealCard(
                  title: meal.name,
                  calories: mealCals.toInt(),
                  items: meal.foods.map((f) =>
                      '${f.name} - ${f.calories.toInt()} cal').toList(),
                  icon: mealEmoji,
                ),
              );
            }),
            const SizedBox(height: 8),

            AppButton(
              label: 'Add Meal',
              icon: Icons.add,
              onPressed: () {
                _showFoodSearchSheet(context, ref);
              },
            ),
            const SizedBox(height: 16),
            // Ad banner for free tier users
            const AdBannerWidget(placement: AdPlacement.homeBanner),
          ],
        ),
      ),
    );
  }

  String _mealEmoji(String name) {
    switch (name.toLowerCase()) {
      case 'breakfast':
        return '\ud83c\udf73';
      case 'lunch':
        return '\ud83c\udf5b';
      case 'dinner':
        return '\ud83c\udf7d\ufe0f';
      case 'snack':
        return '\ud83c\udf4e';
      default:
        return '\ud83c\udf7d\ufe0f';
    }
  }

  void _showFoodSearchSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.text3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                autofocus: true,
                onChanged: (v) {
                  ref.read(foodSearchQueryProvider.notifier).state = v;
                },
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: 'Search foods...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: AppColors.bgTertiary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Consumer(builder: (context, ref, _) {
                final results = ref.watch(foodSearchResultsProvider);
                if (results.isEmpty) {
                  return Center(
                    child: Text('Search for foods to add',
                        style: AppTypography.caption),
                  );
                }
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final food = results[index];
                    return ListTile(
                      title: Text(food.name, style: AppTypography.body),
                      subtitle: Text(
                        '${food.calories.toInt()} cal  |  P: ${food.protein.toInt()}g  C: ${food.carbs.toInt()}g  F: ${food.fat.toInt()}g',
                        style: AppTypography.caption,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${food.name}')),
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroCircle extends StatelessWidget {
  final String label;
  final int current;
  final int target;
  final Color color;
  final String unit;
  final double progress;

  const _MacroCircle({
    required this.label,
    required this.current,
    required this.target,
    required this.color,
    required this.unit,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 36,
      lineWidth: 5,
      percent: progress.clamp(0.0, 1.0),
      progressColor: color,
      backgroundColor: AppColors.bgTertiary,
      circularStrokeCap: CircularStrokeCap.round,
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$current',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Text(
            unit,
            style: AppTypography.caption.copyWith(fontSize: 9),
          ),
        ],
      ),
      footer: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(label,
            style: AppTypography.caption.copyWith(fontSize: 10)),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title;
  final int calories;
  final List<String> items;
  final String icon;

  const _MealCard({
    required this.title,
    required this.calories,
    required this.items,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusPill),
                ),
                child: Text(
                  '$calories cal',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.text3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(item, style: AppTypography.caption),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
