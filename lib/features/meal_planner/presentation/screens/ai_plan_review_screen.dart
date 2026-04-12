import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_genius/config/theme/app_colors.dart';
import 'package:gym_genius/config/theme/app_typography.dart';
import 'package:gym_genius/config/theme/app_dimensions.dart';
import 'package:gym_genius/core/widgets/app_button.dart';
import 'package:gym_genius/core/widgets/app_card.dart';
import 'package:gym_genius/core/widgets/stat_tile.dart';
import 'package:gym_genius/features/meal_planner/domain/meal_plan_model.dart';
import 'package:gym_genius/features/meal_planner/presentation/providers/meal_planner_providers.dart';

class AiPlanReviewScreen extends ConsumerWidget {
  const AiPlanReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(draftMealPlanProvider);

    if (plan == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          backgroundColor: AppColors.bgPrimary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text('Review Your Plan', style: AppTypography.h2),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.text3, size: 48),
                const SizedBox(height: 12),
                Text('No plan to review', style: AppTypography.body),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Generate New Plan',
                  onPressed: () => context.go('/ai-meal-generator'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalCalories = plan.days.fold<int>(
        0, (sum, d) => sum + d.totalCalories);
    final avgCal = plan.days.isEmpty
        ? 0
        : (totalCalories / plan.days.length).round();
    final avgProtein = plan.days.isEmpty
        ? 0
        : (plan.days.fold<int>(0, (s, d) => s + d.totalProtein) /
                plan.days.length)
            .round();
    final avgCarbs = plan.days.isEmpty
        ? 0
        : (plan.days.fold<int>(0, (s, d) => s + d.totalCarbs) /
                plan.days.length)
            .round();
    final avgFat = plan.days.isEmpty
        ? 0
        : (plan.days.fold<int>(0, (s, d) => s + d.totalFat) /
                plan.days.length)
            .round();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('Review Your Plan', style: AppTypography.h2),
        actions: [
          TextButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.refresh,
                size: 18, color: AppColors.accent),
            label: Text(
              'Regenerate',
              style: AppTypography.caption.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.padding2XL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan summary card
                    Container(
                      padding:
                          const EdgeInsets.all(AppDimensions.paddingLG),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.2),
                            AppColors.accentSecondary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusCard),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('\u2728',
                                  style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(plan.name,
                                    style: AppTypography.h2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${plan.days.length} day plan  \u2022  $totalCalories total cal',
                            style: AppTypography.caption,
                          ),
                          const SizedBox(height: 16),
                          Text('Daily Average',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.text2,
                                fontWeight: FontWeight.w700,
                              )),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: StatTile(
                                    label: 'Cal', value: '$avgCal'),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: StatTile(
                                    label: 'Protein', value: '${avgProtein}g'),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: StatTile(
                                    label: 'Carbs', value: '${avgCarbs}g'),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: StatTile(
                                    label: 'Fat', value: '${avgFat}g'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Daily Breakdown', style: AppTypography.h2),
                    const SizedBox(height: 12),
                    ...plan.days.asMap().entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _DayExpansionCard(
                          index: entry.key,
                          day: entry.value,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: const BoxDecoration(
                color: AppColors.bgPrimary,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: AppButton(
                label: 'Save Plan',
                icon: Icons.check_circle_outline,
                onPressed: () async {
                  await ref
                      .read(mealPlanRepositoryProvider)
                      .saveMealPlan(plan);
                  ref.read(draftMealPlanProvider.notifier).state = null;
                  if (context.mounted) {
                    context.go('/meal-planner');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meal plan saved!')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayExpansionCard extends StatefulWidget {
  final int index;
  final DailyMealPlan day;

  const _DayExpansionCard({required this.index, required this.day});

  @override
  State<_DayExpansionCard> createState() => _DayExpansionCardState();
}

class _DayExpansionCardState extends State<_DayExpansionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'D${widget.index + 1}',
                    style: AppTypography.button.copyWith(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dayName(widget.day.date),
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.day.totalCalories} cal \u2022 ${widget.day.totalProtein}g protein',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.text3,
              ),
            ],
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),
            ...widget.day.meals.map((meal) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.bgTertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _mealEmoji(meal.mealType),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meal.recipeName,
                              style: AppTypography.body.copyWith(
                                  fontWeight: FontWeight.w600),
                            ),
                            Text(
                              meal.mealType.replaceAll('_', ' '),
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${meal.calories} cal',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  String _dayName(DateTime d) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return names[(d.weekday - 1) % 7];
  }

  String _mealEmoji(String type) {
    switch (type) {
      case 'breakfast':
        return '\ud83c\udf73';
      case 'lunch':
        return '\ud83c\udf5b';
      case 'dinner':
        return '\ud83c\udf7d\ufe0f';
      case 'snack':
        return '\ud83c\udf4e';
      default:
        return '\ud83c\udf74';
    }
  }
}
