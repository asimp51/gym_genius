import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_genius/config/theme/app_colors.dart';
import 'package:gym_genius/config/theme/app_typography.dart';
import 'package:gym_genius/config/theme/app_dimensions.dart';
import 'package:gym_genius/core/widgets/app_button.dart';
import 'package:gym_genius/core/widgets/app_card.dart';
import 'package:gym_genius/features/meal_planner/presentation/providers/meal_planner_providers.dart';

class MealPrepScreen extends ConsumerWidget {
  const MealPrepScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prepRecipes = ref.watch(mealPrepRecipesProvider);
    final totalCookTime = prepRecipes.fold<int>(
      0,
      (sum, r) => sum + r.totalTimeMinutes,
    );

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Meal Prep Mode', style: AppTypography.h2),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.padding2XL,
            AppDimensions.paddingLG,
            AppDimensions.padding2XL,
            AppDimensions.bottomNavHeight + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
                ),
                child: Row(
                  children: [
                    const Text('\ud83c\udf72',
                        style: TextStyle(fontSize: 44)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cook Once, Eat 4 Times',
                            style: AppTypography.h2
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Batch cook your week in one session.',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.restaurant,
                      label: 'Recipes',
                      value: '${prepRecipes.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer_outlined,
                      label: 'Total Time',
                      value: '${totalCookTime}m',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.inventory_2_outlined,
                      label: 'Servings',
                      value: '${prepRecipes.length * 4}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Selected Recipes', style: AppTypography.h2),
              const SizedBox(height: 12),
              if (prepRecipes.isEmpty)
                AppCard(
                  onTap: () => context.push('/recipe-library'),
                  child: Column(
                    children: [
                      const Icon(Icons.add_circle_outline,
                          size: 40, color: AppColors.accent),
                      const SizedBox(height: 10),
                      Text('Add recipes to prep',
                          style: AppTypography.body),
                      const SizedBox(height: 4),
                      Text(
                        'Browse the library and flag recipes for meal prep',
                        textAlign: TextAlign.center,
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                )
              else
                ...prepRecipes.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppColors.gradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text('\ud83c\udf72',
                                    style: TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.name,
                                    style: AppTypography.body.copyWith(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '4x servings  \u2022  ${r.totalTimeMinutes} min',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${r.caloriesPerServing * 4} cal',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              const SizedBox(height: 24),
              Text('Combined Shopping List', style: AppTypography.h2),
              const SizedBox(height: 12),
              if (prepRecipes.isNotEmpty)
                Builder(builder: (context) {
                  final merged = <String, double>{};
                  final units = <String, String>{};
                  for (final r in prepRecipes) {
                    for (final ing in r.ingredients) {
                      merged.update(
                        ing.name,
                        (v) => v + ing.amount * 4,
                        ifAbsent: () => ing.amount * 4,
                      );
                      units[ing.name] = ing.unit;
                    }
                  }
                  final entries = merged.entries.toList();
                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: entries
                          .take(10)
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      size: 18,
                                      color: AppColors.success),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(e.key,
                                        style: AppTypography.body),
                                  ),
                                  Text(
                                    '${_fmt(e.value)} ${units[e.key] ?? ''}',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                })
              else
                AppCard(
                  child: Text('Select recipes to see shopping list',
                      style: AppTypography.caption),
                ),
              const SizedBox(height: 24),
              Text('Batch Cooking Schedule', style: AppTypography.h2),
              const SizedBox(height: 12),
              if (prepRecipes.isNotEmpty)
                ...prepRecipes.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: AppColors.gradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.value.name,
                                  style: AppTypography.body.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Prep: ${entry.value.prepTimeMinutes}m  |  Cook: ${entry.value.cookTimeMinutes}m',
                                  style: AppTypography.caption,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 24),
              Text('Storage Instructions', style: AppTypography.h2),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StorageTip(
                      emoji: '\ud83c\udf21\ufe0f',
                      text:
                          'Cool meals to room temperature before sealing containers.',
                    ),
                    _StorageTip(
                      emoji: '\ud83e\uddca',
                      text: 'Refrigerate up to 4 days in airtight containers.',
                    ),
                    _StorageTip(
                      emoji: '\u2744\ufe0f',
                      text: 'Freeze up to 3 months for longer storage.',
                    ),
                    _StorageTip(
                      emoji: '\ud83d\udd25',
                      text: 'Reheat thoroughly to 165\u00b0F before serving.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Start Prep Session',
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Prep session started!')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmt(double v) {
    if (v == v.toInt()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.stat),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _StorageTip extends StatelessWidget {
  final String emoji;
  final String text;
  const _StorageTip({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppTypography.body),
          ),
        ],
      ),
    );
  }
}
