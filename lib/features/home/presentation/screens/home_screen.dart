import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gamification/presentation/providers/gamification_providers.dart';
import '../../../workouts/presentation/providers/workout_providers.dart';
import '../../../workouts/presentation/providers/active_workout_provider.dart';
import '../../../../core/widgets/ad_banner_widget.dart';
import '../../../../services/ad_service.dart';
import '../../../../services/ai_usage_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final level = ref.watch(currentLevelProvider);
    final levelTitle = ref.watch(levelTitleProvider);
    final levelProgress = ref.watch(levelProgressProvider);
    final currentXp = ref.watch(currentXpProvider);
    final xpForNext = ref.watch(xpForNextLevelProvider);
    final weekStats = ref.watch(thisWeekStatsProvider);
    final templates = ref.watch(userTemplatesProvider);
    final history = ref.watch(workoutHistoryProvider);
    final recentWorkouts = history.take(3).toList();

    final userName = user?.displayName.split(' ').first ?? 'Athlete';
    final streak = user?.stats.currentStreak ?? 0;
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final suggestedTemplate = templates.isNotEmpty ? templates.first : null;

    final weekWorkouts = weekStats['workouts'] as int? ?? 0;
    final weekVolume = weekStats['volume'] as double? ?? 0;
    final weekPrs = weekStats['prs'] as int? ?? 0;

    return Scaffold(
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
              // Greeting row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey, $userName \ud83d\udc4b',
                        style: AppTypography.h1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        today,
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                  // Streak badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusPill),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('\ud83d\udd25',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          '$streak day streak',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // XP Progress bar
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: AppColors.gradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'LVL $level',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(levelTitle,
                                style: AppTypography.body),
                          ],
                        ),
                        Text(
                          '${_formatNumber(currentXp)} / ${_formatNumber(xpForNext)} XP',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: levelProgress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.bgTertiary,
                        color: AppColors.accent,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Today's Workout card
              SectionHeader(
                title: "Today's Workout",
                actionText: 'Change',
                onAction: () => context.go('/workouts'),
              ),
              const SizedBox(height: 12),
              if (suggestedTemplate != null)
                AppCard(
                  onTap: () {
                    ref.read(selectedTemplateProvider.notifier).state = suggestedTemplate;
                    context.push('/template-detail');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(suggestedTemplate.name,
                                style: AppTypography.h3),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Recommended',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.success,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        children: suggestedTemplate.targetMuscles
                            .map((m) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgTertiary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    m,
                                    style: AppTypography.caption
                                        .copyWith(fontSize: 10),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _InfoChip(
                              icon: Icons.fitness_center,
                              label: '${suggestedTemplate.exercises.length} exercises'),
                          const SizedBox(width: 16),
                          _InfoChip(
                              icon: Icons.timer_outlined,
                              label: '~${suggestedTemplate.estimatedMinutes} min'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Start Workout',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () {
                          ref.read(activeWorkoutProvider.notifier).startFromTemplate(suggestedTemplate);
                          context.push('/active-workout');
                        },
                      ),
                    ],
                  ),
                )
              else
                AppCard(
                  child: Column(
                    children: [
                      Text('No templates yet', style: AppTypography.body),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Start Empty Workout',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () {
                          ref.read(activeWorkoutProvider.notifier).startEmpty('Quick Workout');
                          context.push('/active-workout');
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Quick stats
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'This Week',
                      value: '$weekWorkouts',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                      label: 'Volume',
                      value: _formatVolume(weekVolume),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                      label: 'PRs',
                      value: '$weekPrs',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ad banner for free tier users
              const AdBannerWidget(placement: AdPlacement.homeBanner),
              const SizedBox(height: 8),

              // Recent Activity
              SectionHeader(
                title: 'Recent Activity',
                actionText: 'See All',
                onAction: () => context.go('/progress'),
              ),
              const SizedBox(height: 12),
              if (recentWorkouts.isEmpty)
                AppCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('No recent workouts', style: AppTypography.caption),
                    ),
                  ),
                )
              else
                ...recentWorkouts.map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        padding:
                            const EdgeInsets.all(AppDimensions.paddingMD),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(w.name,
                                      style: AppTypography.body.copyWith(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(_timeAgo(w.finishedAt),
                                      style: AppTypography.caption),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${w.durationMinutes} min',
                                    style: AppTypography.caption
                                        .copyWith(color: AppColors.text1)),
                                const SizedBox(height: 2),
                                Text('${_formatVolume(w.totalVolume)} lbs',
                                    style: AppTypography.caption),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),
              const SizedBox(height: 24),

              // AI Credits indicator
              Builder(builder: (context) {
                final tier = user?.subscription.tier ?? 'free';
                final aiUsage = ref.watch(aiUsageServiceProvider);
                final used = aiUsage.usageCount;
                final limit = aiUsage.getLimit(tier);
                final isPremium = tier == 'premium';
                return GestureDetector(
                  onTap: isPremium
                      ? null
                      : () => context.push('/subscription'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusCard),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Text('\ud83e\udd16',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          'AI: $used/$limit',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: aiUsage
                                  .usagePercent(tier)
                                  .clamp(0.0, 1.0),
                              backgroundColor:
                                  AppColors.bgTertiary,
                              color: aiUsage.usagePercent(tier) >= 1.0
                                  ? AppColors.error
                                  : AppColors.accent,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        if (!isPremium) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right,
                              color: AppColors.text3, size: 18),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),

              // AI recommendation card
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard),
                  border: const Border(
                    left: BorderSide(color: AppColors.accent, width: 3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('\ud83e\udd16',
                                  style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              Text('AI Insight',
                                  style: AppTypography.body.copyWith(
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your bench press has plateaued. Try adding pause reps this week to break through.',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () => context.push('/ai-chat'),
                      icon: const Icon(Icons.chat_bubble_outline,
                          color: AppColors.accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Meal Planner card
              GestureDetector(
                onTap: () => context.push('/meal-planner'),
                child: Container(
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
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppColors.gradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('\ud83c\udf7d\ufe0f',
                              style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Smart Meal Planner',
                                style: AppTypography.body.copyWith(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(
                              'AI-powered weekly meal plans & grocery lists',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.accent),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return NumberFormat('#,###').format(n);
  }

  String _formatVolume(double v) {
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(1)}k';
    }
    return v.toStringAsFixed(0);
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM d').format(dt);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.text3),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
