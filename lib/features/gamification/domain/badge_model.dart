class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String category; // workout, strength, consistency, social, special
  final String requirementDescription;
  final int requiredValue;
  final bool isSecret;

  const BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.category,
    required this.requirementDescription,
    required this.requiredValue,
    this.isSecret = false,
  });

  BadgeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    String? category,
    String? requirementDescription,
    int? requiredValue,
    bool? isSecret,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      requirementDescription:
          requirementDescription ?? this.requirementDescription,
      requiredValue: requiredValue ?? this.requiredValue,
      isSecret: isSecret ?? this.isSecret,
    );
  }

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String,
      category: json['category'] as String,
      requirementDescription: json['requirementDescription'] as String,
      requiredValue: json['requiredValue'] as int,
      isSecret: json['isSecret'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'emoji': emoji,
        'category': category,
        'requirementDescription': requirementDescription,
        'requiredValue': requiredValue,
        'isSecret': isSecret,
      };
}

/// XP constants for various actions in the app.
abstract class XpConstants {
  static const int workoutComplete = 100;
  static const int personalRecord = 50;
  static const int streakDay = 20;
  static const int firstWorkout = 200;
  static const int shareWorkout = 30;
  static const int badgeEarned = 75;
}

/// Utility class for calculating level from XP.
///
/// Each level requires progressively more XP:
/// Level 1: 0 XP
/// Level 2: 100 XP
/// Level 3: 300 XP
/// Level 4: 600 XP
/// Level N: sum of (100 * (N-1)) for all levels up to N
abstract class LevelCalculator {
  /// Returns the current level for the given total XP.
  static int levelFromXp(int xp) {
    int level = 1;
    int xpNeeded = 0;
    while (true) {
      xpNeeded += 100 * level;
      if (xp < xpNeeded) break;
      level++;
    }
    return level;
  }

  /// Returns total XP required to reach the given level.
  static int xpForLevel(int level) {
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += 100 * i;
    }
    return total;
  }

  /// Returns XP needed from current XP to reach next level.
  static int xpToNextLevel(int currentXp) {
    final currentLevel = levelFromXp(currentXp);
    final nextLevelXp = xpForLevel(currentLevel + 1);
    return nextLevelXp - currentXp;
  }

  /// Returns progress (0.0 - 1.0) within current level.
  static double levelProgress(int currentXp) {
    final currentLevel = levelFromXp(currentXp);
    final currentLevelXp = xpForLevel(currentLevel);
    final nextLevelXp = xpForLevel(currentLevel + 1);
    final levelRange = nextLevelXp - currentLevelXp;
    if (levelRange == 0) return 0;
    return (currentXp - currentLevelXp) / levelRange;
  }
}

/// Predefined badges that ship with the app.
class PredefinedBadges {
  PredefinedBadges._();

  static List<BadgeModel> get all => [
        // Workout badges
        const BadgeModel(
          id: 'first_workout',
          name: 'First Steps',
          description: 'Complete your first workout',
          emoji: '\u{1F476}',
          category: 'workout',
          requirementDescription: 'Complete 1 workout',
          requiredValue: 1,
        ),
        const BadgeModel(
          id: 'ten_workouts',
          name: 'Getting Serious',
          description: 'Complete 10 workouts',
          emoji: '\u{1F4AA}',
          category: 'workout',
          requirementDescription: 'Complete 10 workouts',
          requiredValue: 10,
        ),
        const BadgeModel(
          id: 'fifty_workouts',
          name: 'Gym Regular',
          description: 'Complete 50 workouts',
          emoji: '\u{1F3CB}\u{FE0F}',
          category: 'workout',
          requirementDescription: 'Complete 50 workouts',
          requiredValue: 50,
        ),
        const BadgeModel(
          id: 'hundred_workouts',
          name: 'Century Club',
          description: 'Complete 100 workouts',
          emoji: '\u{1F4AF}',
          category: 'workout',
          requirementDescription: 'Complete 100 workouts',
          requiredValue: 100,
        ),

        // Strength badges
        const BadgeModel(
          id: 'first_pr',
          name: 'Record Breaker',
          description: 'Set your first personal record',
          emoji: '\u{1F3C6}',
          category: 'strength',
          requirementDescription: 'Set 1 personal record',
          requiredValue: 1,
        ),
        const BadgeModel(
          id: 'ten_prs',
          name: 'PR Machine',
          description: 'Set 10 personal records',
          emoji: '\u{1F525}',
          category: 'strength',
          requirementDescription: 'Set 10 personal records',
          requiredValue: 10,
        ),
        const BadgeModel(
          id: 'bodyweight_bench',
          name: 'Bodyweight Bench',
          description: 'Bench press your bodyweight',
          emoji: '\u{1F4B0}',
          category: 'strength',
          requirementDescription: 'Bench press your bodyweight',
          requiredValue: 1,
        ),
        const BadgeModel(
          id: 'total_volume_10k',
          name: 'Volume King',
          description: 'Lift 10,000 kg total volume in a single workout',
          emoji: '\u{1F451}',
          category: 'strength',
          requirementDescription: 'Lift 10,000 kg in one workout',
          requiredValue: 10000,
        ),

        // Consistency badges
        const BadgeModel(
          id: 'streak_3',
          name: 'Warming Up',
          description: 'Maintain a 3-day workout streak',
          emoji: '\u{2B50}',
          category: 'consistency',
          requirementDescription: 'Maintain a 3-day streak',
          requiredValue: 3,
        ),
        const BadgeModel(
          id: 'streak_7',
          name: 'Week Warrior',
          description: 'Maintain a 7-day workout streak',
          emoji: '\u{1F31F}',
          category: 'consistency',
          requirementDescription: 'Maintain a 7-day streak',
          requiredValue: 7,
        ),
        const BadgeModel(
          id: 'streak_30',
          name: 'Monthly Madness',
          description: 'Maintain a 30-day workout streak',
          emoji: '\u{1F320}',
          category: 'consistency',
          requirementDescription: 'Maintain a 30-day streak',
          requiredValue: 30,
        ),
        const BadgeModel(
          id: 'streak_100',
          name: 'Unstoppable',
          description: 'Maintain a 100-day workout streak',
          emoji: '\u{2604}\u{FE0F}',
          category: 'consistency',
          requirementDescription: 'Maintain a 100-day streak',
          requiredValue: 100,
        ),
        const BadgeModel(
          id: 'early_bird',
          name: 'Early Bird',
          description: 'Complete 10 workouts before 7 AM',
          emoji: '\u{1F426}',
          category: 'consistency',
          requirementDescription: 'Complete 10 workouts before 7 AM',
          requiredValue: 10,
        ),
        const BadgeModel(
          id: 'night_owl',
          name: 'Night Owl',
          description: 'Complete 10 workouts after 9 PM',
          emoji: '\u{1F989}',
          category: 'consistency',
          requirementDescription: 'Complete 10 workouts after 9 PM',
          requiredValue: 10,
        ),

        // Social badges
        const BadgeModel(
          id: 'first_share',
          name: 'Show Off',
          description: 'Share your first workout',
          emoji: '\u{1F4E2}',
          category: 'social',
          requirementDescription: 'Share 1 workout',
          requiredValue: 1,
        ),
        const BadgeModel(
          id: 'ten_shares',
          name: 'Influencer',
          description: 'Share 10 workouts',
          emoji: '\u{1F4F1}',
          category: 'social',
          requirementDescription: 'Share 10 workouts',
          requiredValue: 10,
        ),
        const BadgeModel(
          id: 'ten_likes',
          name: 'Crowd Favorite',
          description: 'Receive 10 likes on your posts',
          emoji: '\u{2764}\u{FE0F}',
          category: 'social',
          requirementDescription: 'Receive 10 likes',
          requiredValue: 10,
        ),

        // Special badges
        const BadgeModel(
          id: 'level_10',
          name: 'Dedicated',
          description: 'Reach level 10',
          emoji: '\u{1F396}\u{FE0F}',
          category: 'special',
          requirementDescription: 'Reach level 10',
          requiredValue: 10,
        ),
        const BadgeModel(
          id: 'all_muscle_groups',
          name: 'Well Rounded',
          description: 'Train every muscle group in a single week',
          emoji: '\u{1F4AA}',
          category: 'special',
          requirementDescription: 'Train all muscle groups in one week',
          requiredValue: 1,
        ),
        const BadgeModel(
          id: 'marathon_workout',
          name: 'Marathon Session',
          description: 'Complete a workout lasting over 2 hours',
          emoji: '\u{23F1}\u{FE0F}',
          category: 'special',
          requirementDescription: 'Complete a 2+ hour workout',
          requiredValue: 120,
          isSecret: true,
        ),
      ];
}
