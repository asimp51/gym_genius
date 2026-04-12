import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/badge_model.dart';

class XpEvent {
  final String reason;
  final int amount;
  final DateTime timestamp;

  const XpEvent({required this.reason, required this.amount, required this.timestamp});
}

class GamificationRepository {
  int _totalXp = 2450;
  final List<String> _earnedBadgeIds = ['first_step', 'week_warrior', 'pr_crusher', 'iron_chest', 'volume_king', 'quick_dirty'];
  final List<XpEvent> _recentEvents = [];

  GamificationRepository() {
    _seedMockEvents();
  }

  // --- XP ---

  int get totalXp => _totalXp;

  int get currentLevel => calculateLevel(_totalXp);

  double get levelProgress => calculateLevelProgress(_totalXp);

  int get xpForNextLevel => xpRequiredForLevel(currentLevel + 1);

  int get xpInCurrentLevel {
    final currentLevelXp = xpRequiredForLevel(currentLevel);
    return _totalXp - currentLevelXp;
  }

  int get xpNeededForNextLevel {
    return xpForNextLevel - _totalXp;
  }

  XpEvent awardXP(int amount, String reason) {
    _totalXp += amount;
    final event = XpEvent(reason: reason, amount: amount, timestamp: DateTime.now());
    _recentEvents.insert(0, event);
    return event;
  }

  List<XpEvent> get recentEvents => List.unmodifiable(_recentEvents);

  // --- Levels ---

  static int calculateLevel(int xp) {
    return (sqrt(xp / 100)).floor() + 1;
  }

  static int xpRequiredForLevel(int level) {
    return ((level - 1) * (level - 1)) * 100;
  }

  static double calculateLevelProgress(int xp) {
    final level = calculateLevel(xp);
    final currentLevelXp = xpRequiredForLevel(level);
    final nextLevelXp = xpRequiredForLevel(level + 1);
    final range = nextLevelXp - currentLevelXp;
    if (range == 0) return 1.0;
    return (xp - currentLevelXp) / range;
  }

  static String levelTitle(int level) {
    if (level < 5) return 'Iron Novice';
    if (level < 10) return 'Steel Apprentice';
    if (level < 15) return 'Bronze Lifter';
    if (level < 20) return 'Silver Warrior';
    if (level < 25) return 'Gold Champion';
    if (level < 30) return 'Platinum Beast';
    if (level < 40) return 'Diamond Elite';
    if (level < 50) return 'Titan';
    return 'Legend';
  }

  // --- Badges ---

  List<String> get earnedBadgeIds => List.unmodifiable(_earnedBadgeIds);

  List<BadgeModel> get allBadges => PredefinedBadges.all;

  List<BadgeModel> get earnedBadges =>
      PredefinedBadges.all.where((b) => _earnedBadgeIds.contains(b.id)).toList();

  List<BadgeModel> get lockedBadges =>
      PredefinedBadges.all.where((b) => !_earnedBadgeIds.contains(b.id)).toList();

  bool hasBadge(String badgeId) => _earnedBadgeIds.contains(badgeId);

  bool awardBadge(String badgeId) {
    if (_earnedBadgeIds.contains(badgeId)) return false;
    _earnedBadgeIds.add(badgeId);
    awardXP(XpConstants.badgeEarned, 'Badge earned');
    return true;
  }

  /// Checks all badge conditions against current user stats.
  /// Returns list of newly awarded badge IDs.
  List<String> checkAndAwardBadges({
    required int totalWorkouts,
    required double totalVolume,
    required int currentStreak,
    required int totalPRs,
    required double? bench1RM,
    required double? bodyWeight,
    required int legWorkouts,
    required int cardioSessions,
    required int uniqueExercises,
    required double heaviestLift,
    required int workoutsWithRPE,
    required int sharedWorkouts,
    required int workoutsThisWeek,
    required int earlyWorkouts,
    required int lateWorkouts,
    required int longestWorkoutMinutes,
    required int shortestWorkoutMinutes,
  }) {
    final newBadges = <String>[];

    final checks = <String, bool>{
      'first_step': totalWorkouts >= 1,
      'week_warrior': currentStreak >= 7,
      'century_club': totalWorkouts >= 100,
      'pr_crusher': totalPRs >= 10,
      'iron_chest': bench1RM != null && bodyWeight != null && bench1RM >= bodyWeight,
      'volume_king': totalVolume >= 100000,
      'consistent': currentStreak >= 30,
      'beast_mode': workoutsThisWeek >= 5,
      'perfect_week': workoutsThisWeek >= 6,
      'leg_day_hero': legWorkouts >= 20,
      'early_bird': earlyWorkouts >= 10,
      'night_owl': lateWorkouts >= 10,
      'social_butterfly': sharedWorkouts >= 10,
      'marathon': longestWorkoutMinutes >= 90,
      'quick_dirty': shortestWorkoutMinutes > 0 && shortestWorkoutMinutes <= 30,
      'diversity': uniqueExercises >= 50,
      'heavy_lifter': heaviestLift >= 200,
      'cardio_king': cardioSessions >= 20,
      'form_master': workoutsWithRPE >= 100,
      'legend': currentLevel >= 50,
    };

    for (final entry in checks.entries) {
      if (entry.value && !_earnedBadgeIds.contains(entry.key)) {
        _earnedBadgeIds.add(entry.key);
        newBadges.add(entry.key);
      }
    }

    // Award XP for each new badge
    for (final _ in newBadges) {
      awardXP(XpConstants.badgeEarned, 'Badge earned');
    }

    return newBadges;
  }

  double getBadgeProgress(String badgeId, {
    int totalWorkouts = 0,
    double totalVolume = 0,
    int currentStreak = 0,
    int totalPRs = 0,
    int legWorkouts = 0,
    int uniqueExercises = 0,
    int sharedWorkouts = 0,
    int cardioSessions = 0,
    int workoutsWithRPE = 0,
  }) {
    if (_earnedBadgeIds.contains(badgeId)) return 1.0;

    switch (badgeId) {
      case 'first_step': return min(1.0, totalWorkouts / 1);
      case 'week_warrior': return min(1.0, currentStreak / 7);
      case 'century_club': return min(1.0, totalWorkouts / 100);
      case 'pr_crusher': return min(1.0, totalPRs / 10);
      case 'volume_king': return min(1.0, totalVolume / 100000);
      case 'consistent': return min(1.0, currentStreak / 30);
      case 'leg_day_hero': return min(1.0, legWorkouts / 20);
      case 'diversity': return min(1.0, uniqueExercises / 50);
      case 'social_butterfly': return min(1.0, sharedWorkouts / 10);
      case 'cardio_king': return min(1.0, cardioSessions / 20);
      case 'form_master': return min(1.0, workoutsWithRPE / 100);
      case 'legend': return min(1.0, currentLevel / 50);
      default: return 0.0;
    }
  }

  void _seedMockEvents() {
    final now = DateTime.now();
    _recentEvents.addAll([
      XpEvent(reason: 'Workout completed', amount: 100, timestamp: now.subtract(const Duration(hours: 2))),
      XpEvent(reason: 'Personal Record!', amount: 50, timestamp: now.subtract(const Duration(hours: 2))),
      XpEvent(reason: 'Streak day', amount: 20, timestamp: now.subtract(const Duration(hours: 2))),
      XpEvent(reason: 'Workout completed', amount: 100, timestamp: now.subtract(const Duration(days: 1))),
      XpEvent(reason: 'Streak day', amount: 20, timestamp: now.subtract(const Duration(days: 1))),
      XpEvent(reason: 'Workout completed', amount: 100, timestamp: now.subtract(const Duration(days: 3))),
      XpEvent(reason: 'Personal Record!', amount: 50, timestamp: now.subtract(const Duration(days: 3))),
    ]);
  }
}

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) => GamificationRepository());
