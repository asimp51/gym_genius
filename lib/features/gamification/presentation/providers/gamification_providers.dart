import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/gamification_repository.dart';
import '../../domain/badge_model.dart';

// Current XP
final currentXpProvider = Provider<int>((ref) {
  return ref.watch(gamificationRepositoryProvider).totalXp;
});

// Current level
final currentLevelProvider = Provider<int>((ref) {
  return ref.watch(gamificationRepositoryProvider).currentLevel;
});

// Level title
final levelTitleProvider = Provider<String>((ref) {
  final level = ref.watch(currentLevelProvider);
  return GamificationRepository.levelTitle(level);
});

// Progress to next level (0.0 - 1.0)
final levelProgressProvider = Provider<double>((ref) {
  return ref.watch(gamificationRepositoryProvider).levelProgress;
});

// XP needed for next level
final xpForNextLevelProvider = Provider<int>((ref) {
  return ref.watch(gamificationRepositoryProvider).xpForNextLevel;
});

// XP earned in current level
final xpInCurrentLevelProvider = Provider<int>((ref) {
  return ref.watch(gamificationRepositoryProvider).xpInCurrentLevel;
});

// All badges
final allBadgesProvider = Provider<List<BadgeModel>>((ref) {
  return ref.watch(gamificationRepositoryProvider).allBadges;
});

// Earned badges
final earnedBadgesProvider = Provider<List<BadgeModel>>((ref) {
  return ref.watch(gamificationRepositoryProvider).earnedBadges;
});

// Locked badges
final lockedBadgesProvider = Provider<List<BadgeModel>>((ref) {
  return ref.watch(gamificationRepositoryProvider).lockedBadges;
});

// Earned badge count
final earnedBadgeCountProvider = Provider<int>((ref) {
  return ref.watch(earnedBadgesProvider).length;
});

// Recent XP events
final recentXpEventsProvider = Provider<List<XpEvent>>((ref) {
  return ref.watch(gamificationRepositoryProvider).recentEvents;
});

// Badge progress for a specific badge
final badgeProgressProvider = Provider.family<double, String>((ref, badgeId) {
  return ref.watch(gamificationRepositoryProvider).getBadgeProgress(badgeId);
});
