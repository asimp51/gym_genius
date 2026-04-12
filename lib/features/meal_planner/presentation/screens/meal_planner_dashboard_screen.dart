import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_genius/config/theme/app_colors.dart';
import 'package:gym_genius/config/theme/app_typography.dart';
import 'package:gym_genius/config/theme/app_dimensions.dart';
import 'package:gym_genius/core/widgets/app_button.dart';
import 'package:gym_genius/core/widgets/app_card.dart';
import 'package:gym_genius/core/widgets/section_header.dart';
import 'package:gym_genius/core/widgets/stat_tile.dart';
import 'package:gym_genius/features/meal_planner/domain/meal_plan_model.dart';
import 'package:gym_genius/features/meal_planner/presentation/providers/meal_planner_providers.dart';

class MealPlannerDashboardScreen extends ConsumerWidget {
  const MealPlannerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlan = ref.watch(activeMealPlanProvider);
    final todayMeals = ref.watch(todayMealsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: Text('Meal Planner', style: AppTypography.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accent),
            onPressed: () => context.push('/ai-meal-generator'),
          ),
        ],
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
              if (activePlan == null)
                _buildEmptyState(context)
              else ...[
                _ActivePlanCard(plan: activePlan),
                const SizedBox(height: 24),
                SectionHeader(
                  title: "Today's Meals",
                  actionText: 'Calendar',
                  onAction: () => context.push('/weekly-meal-calendar'),
                ),
                const SizedBox(height: 12),
                if (todayMeals.isEmpty)
                  _NoMealsCard(
                    onTap: () => context.push('/weekly-meal-calendar'),
                  )
                else
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: todayMeals.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final meal = todayMeals[index];
                        return _TodayMealCard(
                          meal: meal,
                          onToggle: () {
                            ref
                                .read(mealPlanRepositoryProvider)
                                .markMealCompleted(
                                  meal.id,
                                  !meal.isCompleted,
                                );
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),
                Text('Quick Actions', style: AppTypography.h2),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.auto_awesome,
                        label: 'AI Plan',
                        onTap: () => context.push('/ai-meal-generator'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.menu_book_outlined,
                        label: 'Recipes',
                        onTap: () => context.push('/recipe-library'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.shopping_cart_outlined,
                        label: 'Grocery',
                        onTap: () => context.push('/grocery-list'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('This Week', style: AppTypography.h2),
                const SizedBox(height: 12),
                _WeekPills(plan: activePlan),
                const SizedBox(height: 16),
                AppButton.secondary(
                  label: 'Open Meal Prep Mode',
                  icon: Icons.kitchen_outlined,
                  onPressed: () => context.push('/meal-prep'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent.withValues(alpha: 0.15),
                  AppColors.accentSecondary.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('\ud83c\udf7d\ufe0f', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(
                    'No active meal plan',
                    style: AppTypography.h3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Create your first meal plan',
            style: AppTypography.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Let AI build a personalized weekly plan matched to your goals and preferences.',
            textAlign: TextAlign.center,
            style: AppTypography.caption,
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Generate AI Plan',
            icon: Icons.auto_awesome,
            onPressed: () => context.push('/ai-meal-generator'),
          ),
          const SizedBox(height: 10),
          AppButton.secondary(
            label: 'Browse Recipes',
            icon: Icons.menu_book_outlined,
            onPressed: () => context.push('/recipe-library'),
          ),
        ],
      ),
    );
  }
}

class _ActivePlanCard extends StatelessWidget {
  final MealPlan plan;
  const _ActivePlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysRemaining = plan.endDate.difference(now).inDays.clamp(0, 999);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: 0.2),
            AppColors.accentSecondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.name, style: AppTypography.h2),
                    const SizedBox(height: 4),
                    Text(
                      '$daysRemaining day${daysRemaining == 1 ? '' : 's'} remaining',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                ),
                child: Text(
                  'Active',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Calories',
                  value: '${plan.targetCalories}',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: StatTile(
                  label: 'Protein',
                  value: '${plan.targetProtein}g',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: StatTile(
                  label: 'Carbs',
                  value: '${plan.targetCarbs}g',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: StatTile(
                  label: 'Fat',
                  value: '${plan.targetFat}g',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayMealCard extends StatelessWidget {
  final PlannedMeal meal;
  final VoidCallback onToggle;

  const _TodayMealCard({required this.meal, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
          color: meal.isCompleted
              ? AppColors.success.withValues(alpha: 0.5)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _mealLabel(meal.mealType),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: meal.isCompleted
                        ? AppColors.success
                        : Colors.transparent,
                    border: Border.all(
                      color: meal.isCompleted
                          ? AppColors.success
                          : AppColors.text3,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: meal.isCompleted
                      ? const Icon(Icons.check,
                          size: 16, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _mealEmoji(meal.mealType),
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 6),
          Text(
            meal.recipeName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.local_fire_department,
                  size: 14, color: AppColors.warning),
              const SizedBox(width: 2),
              Text('${meal.calories}', style: AppTypography.caption),
              const SizedBox(width: 10),
              Icon(Icons.timer_outlined, size: 14, color: AppColors.text3),
              const SizedBox(width: 2),
              Text('${meal.prepTime} min', style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }

  String _mealLabel(String type) {
    return type.replaceAll('_', ' ').toUpperCase();
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
      case 'pre_workout':
        return '\ud83e\uddc3';
      case 'post_workout':
        return '\ud83e\udd5b';
      default:
        return '\ud83c\udf74';
    }
  }
}

class _NoMealsCard extends StatelessWidget {
  final VoidCallback onTap;
  const _NoMealsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.restaurant_menu, color: AppColors.text3),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No meals planned for today. Tap to add.',
              style: AppTypography.caption,
            ),
          ),
          const Icon(Icons.chevron_right,
              size: 20, color: AppColors.text3),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style:
                  AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekPills extends StatelessWidget {
  final MealPlan plan;
  const _WeekPills({required this.plan});

  @override
  Widget build(BuildContext context) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: plan.days.isEmpty ? 7 : plan.days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          DailyMealPlan? day;
          DateTime date;
          if (plan.days.isNotEmpty && index < plan.days.length) {
            day = plan.days[index];
            date = day.date;
          } else {
            date = plan.startDate.add(Duration(days: index));
          }
          final isToday = date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
          final weekday = labels[(date.weekday - 1) % 7];
          return Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              gradient: isToday ? AppColors.gradient : null,
              color: isToday ? null : AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
              border: Border.all(
                color: isToday ? Colors.transparent : AppColors.border,
              ),
            ),
            child: Column(
              children: [
                Text(
                  weekday,
                  style: AppTypography.caption.copyWith(
                    color: isToday ? Colors.white : AppColors.text2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day}',
                  style: AppTypography.h3.copyWith(
                    color: isToday ? Colors.white : AppColors.text1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day != null ? '${day.totalCalories}' : '-',
                  style: AppTypography.caption.copyWith(
                    color: isToday
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppColors.text3,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
