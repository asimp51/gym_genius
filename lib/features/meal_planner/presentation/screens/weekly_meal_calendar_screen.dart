import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_genius/config/theme/app_colors.dart';
import 'package:gym_genius/config/theme/app_typography.dart';
import 'package:gym_genius/config/theme/app_dimensions.dart';
import 'package:gym_genius/core/widgets/app_card.dart';
import 'package:gym_genius/core/widgets/stat_tile.dart';
import 'package:gym_genius/features/meal_planner/domain/meal_plan_model.dart';
import 'package:gym_genius/features/meal_planner/presentation/providers/meal_planner_providers.dart';

class WeeklyMealCalendarScreen extends ConsumerStatefulWidget {
  const WeeklyMealCalendarScreen({super.key});

  @override
  ConsumerState<WeeklyMealCalendarScreen> createState() =>
      _WeeklyMealCalendarScreenState();
}

class _WeeklyMealCalendarScreenState
    extends ConsumerState<WeeklyMealCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  int _weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(activeMealPlanProvider);
    final weekStart = _startOfWeek(DateTime.now())
        .add(Duration(days: _weekOffset * 7));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.text2),
              onPressed: () => setState(() => _weekOffset--),
            ),
            Text(
              _formatWeekRange(weekStart, weekEnd),
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppColors.text2),
              onPressed: () => setState(() => _weekOffset++),
            ),
          ],
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: () => context.push('/recipe-library'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.padding2XL,
            AppDimensions.paddingLG,
            AppDimensions.padding2XL,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final date = weekStart.add(Duration(days: i));
                    final day = plan?.dayFor(date);
                    final isSelected = _isSameDay(date, _selectedDate);
                    return _DayPill(
                      date: date,
                      totalCalories: day?.totalCalories ?? 0,
                      selected: isSelected,
                      onTap: () => setState(() => _selectedDate = date),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _formatDayLabel(_selectedDate),
                style: AppTypography.h2,
              ),
              const SizedBox(height: 12),
              Builder(builder: (context) {
                final day = plan?.dayFor(_selectedDate);
                if (day == null || day.meals.isEmpty) {
                  return AppCard(
                    child: Column(
                      children: [
                        const Icon(Icons.restaurant_menu,
                            color: AppColors.text3, size: 40),
                        const SizedBox(height: 10),
                        Text('No meals planned for this day',
                            style: AppTypography.body),
                        const SizedBox(height: 4),
                        Text('Tap + to add a meal',
                            style: AppTypography.caption),
                      ],
                    ),
                  );
                }
                return Column(
                  children: day.meals
                      .map(
                        (meal) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _MealRowCard(
                            meal: meal,
                            onToggle: () {
                              ref
                                  .read(mealPlanRepositoryProvider)
                                  .markMealCompleted(
                                      meal.id, !meal.isCompleted);
                            },
                            onSwap: () {
                              context.push('/recipe-library');
                            },
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
              const SizedBox(height: 24),
              if (plan?.dayFor(_selectedDate) != null) ...[
                Text('Daily Totals', style: AppTypography.h2),
                const SizedBox(height: 12),
                Builder(builder: (context) {
                  final day = plan!.dayFor(_selectedDate)!;
                  return Row(
                    children: [
                      Expanded(
                        child: StatTile(
                            label: 'Cal', value: '${day.totalCalories}'),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: StatTile(
                            label: 'Protein',
                            value: '${day.totalProtein}g'),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: StatTile(
                            label: 'Carbs', value: '${day.totalCarbs}g'),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: StatTile(
                            label: 'Fat', value: '${day.totalFat}g'),
                      ),
                    ],
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  DateTime _startOfWeek(DateTime d) {
    return DateTime(d.year, d.month, d.day)
        .subtract(Duration(days: (d.weekday - 1) % 7));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatWeekRange(DateTime start, DateTime end) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[start.month - 1]} ${start.day} - ${end.day}';
  }

  String _formatDayLabel(DateTime d) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return '${days[(d.weekday - 1) % 7]}, ${d.month}/${d.day}';
  }
}

class _DayPill extends StatelessWidget {
  final DateTime date;
  final int totalCalories;
  final bool selected;
  final VoidCallback onTap;

  const _DayPill({
    required this.date,
    required this.totalCalories,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = labels[(date.weekday - 1) % 7];

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.gradient : null,
          color: selected ? null : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: selected ? Colors.transparent : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekday,
              style: AppTypography.caption.copyWith(
                color: selected ? Colors.white : AppColors.text2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.day}',
              style: AppTypography.h3.copyWith(
                color: selected ? Colors.white : AppColors.text1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              totalCalories > 0 ? '$totalCalories' : '-',
              style: AppTypography.caption.copyWith(
                color: selected
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.text3,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealRowCard extends StatelessWidget {
  final PlannedMeal meal;
  final VoidCallback onToggle;
  final VoidCallback onSwap;

  const _MealRowCard({
    required this.meal,
    required this.onToggle,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _mealEmoji(meal.mealType),
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealType[0].toUpperCase() +
                      meal.mealType.substring(1).replaceAll('_', ' '),
                  style: AppTypography.caption
                      .copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: 2),
                Text(
                  meal.recipeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.body
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 12, color: AppColors.warning),
                    const SizedBox(width: 2),
                    Text('${meal.calories}',
                        style: AppTypography.caption),
                    const SizedBox(width: 10),
                    Icon(Icons.timer_outlined,
                        size: 12, color: AppColors.text3),
                    const SizedBox(width: 2),
                    Text('${meal.prepTime}m',
                        style: AppTypography.caption),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz,
                color: AppColors.text2, size: 20),
            onPressed: onSwap,
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: meal.isCompleted
                    ? AppColors.success
                    : Colors.transparent,
                border: Border.all(
                  color:
                      meal.isCompleted ? AppColors.success : AppColors.text3,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: meal.isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
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
