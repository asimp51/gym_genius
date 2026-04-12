class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final UserOnboarding onboarding;
  final UserSettings settings;
  final UserStats stats;
  final UserGamification gamification;
  final UserSubscription subscription;
  final String? orgId; // null = B2C user, set = B2B user
  final String? orgRole; // 'admin', 'trainer', 'member'

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
    required this.onboarding,
    required this.settings,
    required this.stats,
    required this.gamification,
    required this.subscription,
    this.orgId,
    this.orgRole,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserOnboarding? onboarding,
    UserSettings? settings,
    UserStats? stats,
    UserGamification? gamification,
    UserSubscription? subscription,
    String? orgId,
    String? orgRole,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      onboarding: onboarding ?? this.onboarding,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
      gamification: gamification ?? this.gamification,
      subscription: subscription ?? this.subscription,
      orgId: orgId ?? this.orgId,
      orgRole: orgRole ?? this.orgRole,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      onboarding: UserOnboarding.fromJson(
          json['onboarding'] as Map<String, dynamic>),
      settings:
          UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      gamification: UserGamification.fromJson(
          json['gamification'] as Map<String, dynamic>),
      subscription: UserSubscription.fromJson(
          json['subscription'] as Map<String, dynamic>),
      orgId: json['orgId'] as String?,
      orgRole: json['orgRole'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'onboarding': onboarding.toJson(),
        'settings': settings.toJson(),
        'stats': stats.toJson(),
        'gamification': gamification.toJson(),
        'subscription': subscription.toJson(),
        'orgId': orgId,
        'orgRole': orgRole,
      };

  factory UserModel.empty() => UserModel(
        id: '',
        email: '',
        displayName: '',
        createdAt: DateTime.now(),
        onboarding: UserOnboarding.empty(),
        settings: UserSettings.defaults(),
        stats: UserStats.zero(),
        gamification: UserGamification.initial(),
        subscription: UserSubscription.free(),
      );
}

class UserOnboarding {
  final String experienceLevel; // beginner, intermediate, advanced
  final List<String> goals;
  final List<String> equipment;
  final int daysPerWeek;
  final List<String> preferredDays;
  final DateTime? completedAt;

  const UserOnboarding({
    required this.experienceLevel,
    required this.goals,
    required this.equipment,
    required this.daysPerWeek,
    required this.preferredDays,
    this.completedAt,
  });

  UserOnboarding copyWith({
    String? experienceLevel,
    List<String>? goals,
    List<String>? equipment,
    int? daysPerWeek,
    List<String>? preferredDays,
    DateTime? completedAt,
  }) {
    return UserOnboarding(
      experienceLevel: experienceLevel ?? this.experienceLevel,
      goals: goals ?? this.goals,
      equipment: equipment ?? this.equipment,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      preferredDays: preferredDays ?? this.preferredDays,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory UserOnboarding.fromJson(Map<String, dynamic> json) {
    return UserOnboarding(
      experienceLevel: json['experienceLevel'] as String,
      goals: List<String>.from(json['goals'] as List),
      equipment: List<String>.from(json['equipment'] as List),
      daysPerWeek: json['daysPerWeek'] as int,
      preferredDays: List<String>.from(json['preferredDays'] as List),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'experienceLevel': experienceLevel,
        'goals': goals,
        'equipment': equipment,
        'daysPerWeek': daysPerWeek,
        'preferredDays': preferredDays,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory UserOnboarding.empty() => const UserOnboarding(
        experienceLevel: '',
        goals: [],
        equipment: [],
        daysPerWeek: 0,
        preferredDays: [],
      );
}

class UserSettings {
  final String weightUnit; // kg, lb
  final String distanceUnit; // km, mi
  final String measurementUnit; // cm, in
  final String theme; // dark, light, system
  final int restTimerSeconds;
  final String language; // en, ar
  final NotificationSettings notifications;

  const UserSettings({
    required this.weightUnit,
    required this.distanceUnit,
    required this.measurementUnit,
    required this.theme,
    required this.restTimerSeconds,
    this.language = 'en',
    required this.notifications,
  });

  UserSettings copyWith({
    String? weightUnit,
    String? distanceUnit,
    String? measurementUnit,
    String? theme,
    int? restTimerSeconds,
    String? language,
    NotificationSettings? notifications,
  }) {
    return UserSettings(
      weightUnit: weightUnit ?? this.weightUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      theme: theme ?? this.theme,
      restTimerSeconds: restTimerSeconds ?? this.restTimerSeconds,
      language: language ?? this.language,
      notifications: notifications ?? this.notifications,
    );
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      weightUnit: json['weightUnit'] as String,
      distanceUnit: json['distanceUnit'] as String,
      measurementUnit: json['measurementUnit'] as String,
      theme: json['theme'] as String,
      restTimerSeconds: json['restTimerSeconds'] as int,
      language: json['language'] as String? ?? 'en',
      notifications: NotificationSettings.fromJson(
          json['notifications'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'weightUnit': weightUnit,
        'distanceUnit': distanceUnit,
        'measurementUnit': measurementUnit,
        'theme': theme,
        'restTimerSeconds': restTimerSeconds,
        'language': language,
        'notifications': notifications.toJson(),
      };

  factory UserSettings.defaults() => const UserSettings(
        weightUnit: 'kg',
        distanceUnit: 'km',
        measurementUnit: 'cm',
        theme: 'dark',
        restTimerSeconds: 90,
        language: 'en',
        notifications: NotificationSettings(),
      );
}

class NotificationSettings {
  final bool workoutReminders;
  final bool streakReminders;
  final bool aiRecommendations;
  final bool socialActivity;

  const NotificationSettings({
    this.workoutReminders = true,
    this.streakReminders = true,
    this.aiRecommendations = true,
    this.socialActivity = false,
  });

  NotificationSettings copyWith({
    bool? workoutReminders,
    bool? streakReminders,
    bool? aiRecommendations,
    bool? socialActivity,
  }) {
    return NotificationSettings(
      workoutReminders: workoutReminders ?? this.workoutReminders,
      streakReminders: streakReminders ?? this.streakReminders,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
      socialActivity: socialActivity ?? this.socialActivity,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      workoutReminders: json['workoutReminders'] as bool? ?? true,
      streakReminders: json['streakReminders'] as bool? ?? true,
      aiRecommendations: json['aiRecommendations'] as bool? ?? true,
      socialActivity: json['socialActivity'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'workoutReminders': workoutReminders,
        'streakReminders': streakReminders,
        'aiRecommendations': aiRecommendations,
        'socialActivity': socialActivity,
      };
}

class UserStats {
  final int totalWorkouts;
  final double totalVolume;
  final int totalDuration; // minutes
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutAt;

  const UserStats({
    required this.totalWorkouts,
    required this.totalVolume,
    required this.totalDuration,
    required this.currentStreak,
    required this.longestStreak,
    this.lastWorkoutAt,
  });

  UserStats copyWith({
    int? totalWorkouts,
    double? totalVolume,
    int? totalDuration,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastWorkoutAt,
  }) {
    return UserStats(
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalVolume: totalVolume ?? this.totalVolume,
      totalDuration: totalDuration ?? this.totalDuration,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutAt: lastWorkoutAt ?? this.lastWorkoutAt,
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalWorkouts: json['totalWorkouts'] as int,
      totalVolume: (json['totalVolume'] as num).toDouble(),
      totalDuration: json['totalDuration'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      lastWorkoutAt: json['lastWorkoutAt'] != null
          ? DateTime.parse(json['lastWorkoutAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalWorkouts': totalWorkouts,
        'totalVolume': totalVolume,
        'totalDuration': totalDuration,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastWorkoutAt': lastWorkoutAt?.toIso8601String(),
      };

  factory UserStats.zero() => const UserStats(
        totalWorkouts: 0,
        totalVolume: 0,
        totalDuration: 0,
        currentStreak: 0,
        longestStreak: 0,
      );
}

class UserGamification {
  final int xp;
  final int level;
  final List<String> earnedBadgeIds;

  const UserGamification({
    required this.xp,
    required this.level,
    required this.earnedBadgeIds,
  });

  UserGamification copyWith({
    int? xp,
    int? level,
    List<String>? earnedBadgeIds,
  }) {
    return UserGamification(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
    );
  }

  factory UserGamification.fromJson(Map<String, dynamic> json) {
    return UserGamification(
      xp: json['xp'] as int,
      level: json['level'] as int,
      earnedBadgeIds: List<String>.from(json['earnedBadgeIds'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'xp': xp,
        'level': level,
        'earnedBadgeIds': earnedBadgeIds,
      };

  factory UserGamification.initial() => const UserGamification(
        xp: 0,
        level: 1,
        earnedBadgeIds: [],
      );
}

class UserSubscription {
  final String tier; // free, premium
  final String? platform; // ios, android
  final DateTime? expiresAt;
  final String? revenueCatId;

  const UserSubscription({
    required this.tier,
    this.platform,
    this.expiresAt,
    this.revenueCatId,
  });

  UserSubscription copyWith({
    String? tier,
    String? platform,
    DateTime? expiresAt,
    String? revenueCatId,
  }) {
    return UserSubscription(
      tier: tier ?? this.tier,
      platform: platform ?? this.platform,
      expiresAt: expiresAt ?? this.expiresAt,
      revenueCatId: revenueCatId ?? this.revenueCatId,
    );
  }

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      tier: json['tier'] as String,
      platform: json['platform'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      revenueCatId: json['revenueCatId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'tier': tier,
        'platform': platform,
        'expiresAt': expiresAt?.toIso8601String(),
        'revenueCatId': revenueCatId,
      };

  factory UserSubscription.free() => const UserSubscription(tier: 'free');
}
