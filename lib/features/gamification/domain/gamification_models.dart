/// Gamification domain models.
/// Badges, XP events, and level data.

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category; // workout, strength, consistency, social, special
  final int xpReward;
  final bool Function(BadgeCheckContext context) checkCondition;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.xpReward = 75,
    required this.checkCondition,
  });
}

class BadgeCheckContext {
  final int totalWorkouts;
  final int currentStreak;
  final int longestStreak;
  final double totalVolume;
  final int prCount;
  final int level;
  final double? bodyWeight;
  final double? benchMax1RM;
  final int legWorkoutCount;
  final int earlyWorkoutCount;
  final int lateWorkoutCount;
  final int sharedWorkoutCount;
  final int longestWorkoutMinutes;
  final int shortestWorkoutMinutes;
  final int uniqueExerciseCount;
  final double heaviestSingleSet;
  final int cardioSessionCount;
  final int workoutsWithRPE;
  final int workoutsThisWeek;
  final int scheduledDaysHit;
  final int scheduledDaysTotal;

  const BadgeCheckContext({
    this.totalWorkouts = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalVolume = 0,
    this.prCount = 0,
    this.level = 1,
    this.bodyWeight,
    this.benchMax1RM,
    this.legWorkoutCount = 0,
    this.earlyWorkoutCount = 0,
    this.lateWorkoutCount = 0,
    this.sharedWorkoutCount = 0,
    this.longestWorkoutMinutes = 0,
    this.shortestWorkoutMinutes = 999,
    this.uniqueExerciseCount = 0,
    this.heaviestSingleSet = 0,
    this.cardioSessionCount = 0,
    this.workoutsWithRPE = 0,
    this.workoutsThisWeek = 0,
    this.scheduledDaysHit = 0,
    this.scheduledDaysTotal = 0,
  });
}

class XPEvent {
  final String id;
  final String reason;
  final int amount;
  final DateTime timestamp;

  const XPEvent({
    required this.id,
    required this.reason,
    required this.amount,
    required this.timestamp,
  });
}

class BadgeProgress {
  final String badgeId;
  final String badgeName;
  final double progress; // 0.0 - 1.0
  final String progressDescription;
  final bool isEarned;
  final DateTime? earnedAt;

  const BadgeProgress({
    required this.badgeId,
    required this.badgeName,
    required this.progress,
    required this.progressDescription,
    this.isEarned = false,
    this.earnedAt,
  });
}

class LevelInfo {
  final int level;
  final int currentXP;
  final int xpForCurrentLevel;
  final int xpForNextLevel;
  final double progressToNext;

  const LevelInfo({
    required this.level,
    required this.currentXP,
    required this.xpForCurrentLevel,
    required this.xpForNextLevel,
    required this.progressToNext,
  });
}
