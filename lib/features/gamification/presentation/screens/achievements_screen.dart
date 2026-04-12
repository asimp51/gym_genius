import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_typography.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/gamification_providers.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earnedBadges = ref.watch(earnedBadgesProvider);
    final lockedBadges = ref.watch(lockedBadgesProvider);
    final level = ref.watch(currentLevelProvider);
    final levelTitle = ref.watch(levelTitleProvider);
    final currentXp = ref.watch(currentXpProvider);
    final xpForNext = ref.watch(xpForNextLevelProvider);
    final levelProgress = ref.watch(levelProgressProvider);
    final xpInLevel = ref.watch(xpInCurrentLevelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.padding2XL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // XP bar with level
            AppCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'LEVEL $level',
                          style: AppTypography.button.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(levelTitle,
                      style: AppTypography.body
                          .copyWith(color: AppColors.text2)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('$xpInLevel XP', style: AppTypography.caption),
                      Text('$xpForNext XP', style: AppTypography.caption),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: levelProgress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.bgTertiary,
                      color: AppColors.accent,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${xpForNext - xpInLevel} XP to Level ${level + 1}',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Earned badges
            Text('Earned (${earnedBadges.length})',
                style: AppTypography.h2),
            const SizedBox(height: 12),
            earnedBadges.isEmpty
                ? AppCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('No badges earned yet',
                            style: AppTypography.caption),
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: earnedBadges.length,
                    itemBuilder: (context, index) {
                      final badge = earnedBadges[index];
                      return Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.accent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(badge.emoji,
                                  style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            badge.name,
                            style: AppTypography.caption.copyWith(fontSize: 10),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
            const SizedBox(height: 24),

            // Locked badges
            Text('Locked (${lockedBadges.length})',
                style: AppTypography.h2),
            const SizedBox(height: 12),
            lockedBadges.isEmpty
                ? AppCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('All badges earned!',
                            style: AppTypography.caption),
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: lockedBadges.length,
                    itemBuilder: (context, index) {
                      final badge = lockedBadges[index];
                      return Opacity(
                        opacity: 0.4,
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.bgTertiary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(badge.emoji,
                                      style: const TextStyle(fontSize: 24)),
                                  const Icon(Icons.lock,
                                      size: 16, color: AppColors.text3),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              badge.name,
                              style:
                                  AppTypography.caption.copyWith(fontSize: 10),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
