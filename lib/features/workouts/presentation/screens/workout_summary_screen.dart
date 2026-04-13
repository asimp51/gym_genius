import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/stat_tile.dart';
import '../../domain/workout_model.dart';
import '../../../gamification/presentation/providers/gamification_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../social/presentation/providers/social_providers.dart';
import '../../../social/domain/social_models.dart';
import '../../../../core/widgets/ad_banner_widget.dart';
import '../../../../services/ad_service.dart';

class WorkoutSummaryScreen extends ConsumerWidget {
  const WorkoutSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workout = GoRouterState.of(context).extra as WorkoutModel?;
    final currentXp = ref.watch(currentXpProvider);
    final level = ref.watch(currentLevelProvider);
    final levelTitle = ref.watch(levelTitleProvider);

    if (workout == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Summary')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No workout data'),
              const SizedBox(height: 16),
              AppButton(
                label: 'Go Home',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      );
    }

    // Track workout completion and check for interstitial ad
    final adService = ref.read(adServiceProvider);
    adService.onWorkoutCompleted();
    if (adService.shouldShowInterstitial()) {
      adService.showInterstitialAd();
    }

    final durationH = workout.durationMinutes ~/ 60;
    final durationM = workout.durationMinutes % 60;
    final durationStr = durationH > 0
        ? '${durationH}h ${durationM.toString().padLeft(2, '0')}m'
        : '$durationM:00';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        child: Column(
          children: [
            const Text('\ud83c\udf89', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text('Workout Complete!', style: AppTypography.display),
            const SizedBox(height: 4),
            Text(
              workout.name,
              style: AppTypography.body.copyWith(color: AppColors.text2),
            ),
            const SizedBox(height: 24),

            // 2x2 grid of stats
            Row(
              children: [
                Expanded(
                  child: StatTile(label: 'Duration', value: durationStr),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatTile(
                      label: 'Volume',
                      value: _formatVolume(workout.totalVolume)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: StatTile(label: 'Sets', value: '${workout.totalSets}'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatTile(
                      label: 'Exercises',
                      value: '${workout.exercises.length}'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // PR section
            if (workout.personalRecords.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.paddingLG),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD700).withValues(alpha: 0.2),
                      const Color(0xFFFFA500).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusCard),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Text('\ud83c\udfc6',
                        style: TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(
                        workout.personalRecords.length == 1
                            ? 'New Personal Record!'
                            : '${workout.personalRecords.length} Personal Records!',
                        style: AppTypography.h3.copyWith(
                            color: const Color(0xFFFFD700))),
                    const SizedBox(height: 4),
                    ...workout.personalRecords.map((pr) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${pr.exerciseName}: ${pr.value.toStringAsFixed(0)} lbs (est 1RM)',
                            style: AppTypography.body,
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // XP earned
            AppCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('\u2b50', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text('Level $level - $levelTitle',
                          style: AppTypography.stat
                              .copyWith(color: AppColors.accent)),
                      Text('Total XP: $currentXp',
                          style: AppTypography.caption),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // AI insight
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingLG),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusCard),
                border: const Border(
                  left: BorderSide(color: AppColors.accent, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('\ud83e\udd16',
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text('AI Analysis',
                          style: AppTypography.body
                              .copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workout.aiRecommendation ??
                        'Great session! Keep up the consistency and you\'ll see continued progress.',
                    style: AppTypography.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Exercise breakdown
            if (workout.exercises.isNotEmpty)
              ExpansionTile(
                title: Text('Exercise Breakdown',
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600)),
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                iconColor: AppColors.text3,
                children: workout.exercises.map((ex) {
                  final vol = ex.sets.fold<double>(
                      0, (s, set) => s + set.weight * set.reps);
                  return _BreakdownItem(
                    name: ex.exerciseName,
                    sets: '${ex.sets.length}',
                    vol: '${_formatVolume(vol)} lbs',
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),

            // Ad banner for free tier users
            const AdBannerWidget(
                placement: AdPlacement.workoutSummaryBanner),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AppButton.secondary(
                    label: 'Share',
                    icon: Icons.share_outlined,
                    onPressed: () {
                      final user = ref.read(currentUserProvider);
                      if (user != null) {
                        final createPost = ref.read(createPostProvider);
                        createPost(
                          userId: user.id,
                          userName: user.displayName,
                          type: 'workout_summary',
                          content: 'Just completed ${workout.name}!',
                          stats: PostStats(
                            duration: workout.durationMinutes,
                            exercises: workout.exercises.length,
                            volume: workout.totalVolume,
                            prs: workout.personalRecords.length,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Workout shared!')),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Done',
                    onPressed: () => context.go('/home'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatVolume(double v) {
    if (v >= 1000) {
      return '${(v / 1000).toStringAsFixed(v >= 10000 ? 0 : 1)}k';
    }
    return v.toStringAsFixed(0);
  }
}

class _BreakdownItem extends StatelessWidget {
  final String name;
  final String sets;
  final String vol;

  const _BreakdownItem({
    required this.name,
    required this.sets,
    required this.vol,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(name, style: AppTypography.body),
          ),
          SizedBox(
            width: 50,
            child: Text('$sets sets',
                style: AppTypography.caption, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 2,
            child: Text(vol,
                style: AppTypography.caption.copyWith(color: AppColors.text1),
                textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
