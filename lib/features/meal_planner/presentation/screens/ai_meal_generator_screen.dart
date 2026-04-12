import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_genius/config/theme/app_colors.dart';
import 'package:gym_genius/config/theme/app_typography.dart';
import 'package:gym_genius/config/theme/app_dimensions.dart';
import 'package:gym_genius/core/widgets/app_button.dart';
import 'package:gym_genius/features/meal_planner/domain/meal_plan_model.dart';
import 'package:gym_genius/features/meal_planner/presentation/providers/meal_planner_providers.dart';
import 'package:gym_genius/features/auth/presentation/providers/auth_provider.dart';
import 'package:gym_genius/services/ai_usage_service.dart';
import 'package:gym_genius/services/ad_service.dart';

class AiMealGeneratorScreen extends ConsumerStatefulWidget {
  const AiMealGeneratorScreen({super.key});

  @override
  ConsumerState<AiMealGeneratorScreen> createState() =>
      _AiMealGeneratorScreenState();
}

class _AiMealGeneratorScreenState
    extends ConsumerState<AiMealGeneratorScreen> {
  String _goal = 'build_muscle';
  double _calories = 2400;
  double _protein = 180;
  int _days = 7;
  int _mealsPerDay = 4;
  String _budget = 'moderate';
  String _skill = 'intermediate';
  int _cookTime = 30;
  final Set<DietaryRestriction> _restrictions = {};
  bool _isGenerating = false;

  static const _goals = [
    _GoalOption('build_muscle', 'Build Muscle', '\ud83d\udcaa'),
    _GoalOption('lose_weight', 'Lose Weight', '\ud83d\udd25'),
    _GoalOption('maintain', 'Maintain', '\u2696\ufe0f'),
    _GoalOption('bulk', 'Bulk', '\ud83e\udd69'),
    _GoalOption('cut', 'Cut', '\ud83c\udf43'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final tier = user?.subscription.tier ?? 'free';
    final aiUsage = ref.watch(aiUsageServiceProvider);
    final remaining = aiUsage.remaining(tier);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text('AI Meal Generator', style: AppTypography.h2),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.padding2XL,
                AppDimensions.paddingLG,
                AppDimensions.padding2XL,
                120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroHeader(),
                  const SizedBox(height: 24),
                  _SectionLabel('Your Goal'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.4,
                    children: _goals
                        .map((g) => _GoalCard(
                              option: g,
                              selected: _goal == g.value,
                              onTap: () =>
                                  setState(() => _goal = g.value),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('Target Calories'),
                  const SizedBox(height: 4),
                  Text('${_calories.toInt()} kcal',
                      style: AppTypography.statLarge),
                  Slider(
                    value: _calories,
                    min: 1500,
                    max: 4000,
                    divisions: 25,
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.bgTertiary,
                    onChanged: (v) =>
                        setState(() => _calories = v),
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel('Protein Target'),
                  const SizedBox(height: 4),
                  Text('${_protein.toInt()} g',
                      style: AppTypography.statLarge),
                  Slider(
                    value: _protein,
                    min: 100,
                    max: 300,
                    divisions: 20,
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.bgTertiary,
                    onChanged: (v) =>
                        setState(() => _protein = v),
                  ),
                  const SizedBox(height: 16),
                  _SectionLabel('Plan Duration'),
                  const SizedBox(height: 12),
                  _SegmentedSelector<int>(
                    values: const [3, 5, 7],
                    labels: const ['3 days', '5 days', '7 days'],
                    selected: _days,
                    onChanged: (v) => setState(() => _days = v),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('Meals per Day'),
                  const SizedBox(height: 12),
                  _SegmentedSelector<int>(
                    values: const [3, 4, 5, 6],
                    labels: const ['3', '4', '5', '6'],
                    selected: _mealsPerDay,
                    onChanged: (v) =>
                        setState(() => _mealsPerDay = v),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('Dietary Restrictions'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        DietaryRestriction.values.take(8).map((r) {
                      final selected = _restrictions.contains(r);
                      return GestureDetector(
                        onTap: () => setState(() {
                          if (selected) {
                            _restrictions.remove(r);
                          } else {
                            _restrictions.add(r);
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.accent
                                    .withValues(alpha: 0.2)
                                : AppColors.bgSecondary,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusPill),
                            border: Border.all(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            r.displayName,
                            style: AppTypography.caption.copyWith(
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.text2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('Budget Level'),
                  const SizedBox(height: 12),
                  _SegmentedSelector<String>(
                    values: const [
                      'budget',
                      'moderate',
                      'premium'
                    ],
                    labels: const [
                      'Budget',
                      'Moderate',
                      'Premium'
                    ],
                    selected: _budget,
                    onChanged: (v) =>
                        setState(() => _budget = v),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('Cooking Skill'),
                  const SizedBox(height: 12),
                  _SegmentedSelector<String>(
                    values: const [
                      'beginner',
                      'intermediate',
                      'advanced'
                    ],
                    labels: const [
                      'Beginner',
                      'Intermediate',
                      'Advanced'
                    ],
                    selected: _skill,
                    onChanged: (v) =>
                        setState(() => _skill = v),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel('Max Cook Time per Meal'),
                  const SizedBox(height: 12),
                  _SegmentedSelector<int>(
                    values: const [15, 30, 45, 60],
                    labels: const [
                      '15 min',
                      '30 min',
                      '45 min',
                      '60 min'
                    ],
                    selected: _cookTime,
                    onChanged: (v) =>
                        setState(() => _cookTime = v),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Bottom gradient generate button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding:
                    const EdgeInsets.fromLTRB(24, 12, 24, 20),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary
                      .withValues(alpha: 0.95),
                  border: const Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: AppButton(
                  label: _isGenerating
                      ? 'Generating...'
                      : 'Generate Plan ($remaining credits left)',
                  icon: Icons.auto_awesome,
                  isLoading: _isGenerating,
                  onPressed: _isGenerating ? null : _generate,
                ),
              ),
            ),
            if (_isGenerating)
              Container(
                color:
                    AppColors.bgPrimary.withValues(alpha: 0.85),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 4,
                              color: AppColors.accent,
                            ),
                            const Text('\u2728',
                                style:
                                    TextStyle(fontSize: 32)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Cooking up your plan...',
                          style: AppTypography.h3),
                      const SizedBox(height: 6),
                      Text('This usually takes a moment',
                          style: AppTypography.caption),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    final user = ref.read(currentUserProvider);
    final tier = user?.subscription.tier ?? 'free';
    final aiUsage = ref.read(aiUsageServiceProvider);

    // Check AI usage limit before generating
    if (!aiUsage.canUseAi(tier)) {
      _showLimitDialog(tier);
      return;
    }

    // Record the usage
    aiUsage.recordUsage();

    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 2));

    try {
      final plan = await ref
          .read(mealPlanRepositoryProvider)
          .generateAiPlan(
            goal: _goal,
            targetCalories: _calories.toInt(),
            targetProtein: _protein.toInt(),
            days: _days,
            mealsPerDay: _mealsPerDay,
            restrictions: _restrictions.toList(),
            budget: _budget,
            skill: _skill,
            maxCookTime: _cookTime,
          );
      ref.read(draftMealPlanProvider.notifier).state = plan;
      if (mounted) {
        setState(() => _isGenerating = false);
        context.push('/ai-plan-review');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to generate plan')),
        );
      }
    }
  }

  void _showLimitDialog(String tier) {
    final aiUsage = ref.read(aiUsageServiceProvider);
    final daysLeft = aiUsage.daysUntilReset;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text("You've used all your AI credits this month",
            style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'ve used all ${aiUsage.getLimit(tier)} AI credits for this month. '
              'Credits reset in $daysLeft days.',
              style: AppTypography.body,
            ),
            const SizedBox(height: 12),
            if (tier == 'free')
              Text(
                'Upgrade to Premium for 100 AI credits/month with Pro quality!',
                style: AppTypography.caption
                    .copyWith(color: AppColors.accent),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final adService = ref.read(adServiceProvider);
              final watched = await adService.showRewardedAd();
              if (watched) {
                ref
                    .read(aiUsageServiceProvider)
                    .grantBonusUsage(1);
                if (mounted) setState(() {});
              }
            },
            child: Text('Watch Ad for 1 Free Credit',
                style: AppTypography.button
                    .copyWith(color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/subscription');
            },
            child: Text('Upgrade to Premium',
                style: AppTypography.button
                    .copyWith(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _GoalOption {
  final String value;
  final String label;
  final String emoji;
  const _GoalOption(this.value, this.label, this.emoji);
}

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        borderRadius:
            BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child:
                  Text('\u2728', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Let AI Plan Your Week',
                    style: AppTypography.h2),
                const SizedBox(height: 4),
                Text(
                  'Tell us your goals, we\'ll do the rest.',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          AppTypography.h3.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final _GoalOption option;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.bgSecondary,
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusCard),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(option.emoji,
                style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                option.label,
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.accent
                      : AppColors.text1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedSelector<T> extends StatelessWidget {
  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;

  const _SegmentedSelector({
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius:
            BorderRadius.circular(AppDimensions.radiusButton),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: List.generate(values.length, (i) {
          final isSelected = values[i] == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(values[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient:
                      isSelected ? AppColors.gradient : null,
                  borderRadius: BorderRadius.circular(
                      AppDimensions.radiusButton - 4),
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: AppTypography.caption.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.text2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
