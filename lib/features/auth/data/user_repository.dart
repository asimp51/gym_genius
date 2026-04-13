import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';

/// In-memory user store. Will be replaced by Firestore.
class UserRepository {
  final Map<String, UserModel> _users = {};

  UserRepository() {
    // Pre-load a demo user so sign-in works immediately
    final demoUser = UserModel(
      id: 'user_${('demo@gymgenius.com').hashCode.abs()}',
      email: 'demo@gymgenius.com',
      displayName: 'Alex Johnson',
      birthDate: DateTime(1994, 6, 15),
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      onboarding: UserOnboarding(
        experienceLevel: 'intermediate',
        goals: ['Build Muscle', 'Increase Strength'],
        equipment: ['Barbell', 'Dumbbell', 'Cable Machine', 'Bench'],
        daysPerWeek: 4,
        preferredDays: ['Mon', 'Tue', 'Thu', 'Fri'],
        completedAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
      settings: UserSettings.defaults(),
      stats: const UserStats(
        totalWorkouts: 48,
        totalVolume: 285400,
        totalDuration: 2880,
        currentStreak: 3,
        longestStreak: 14,
        lastWorkoutAt: null,
      ),
      gamification: const UserGamification(
        xp: 4850,
        level: 7,
        earnedBadgeIds: [
          'first_step',
          'week_warrior',
          'pr_crusher',
          'volume_king',
          'beast_mode',
          'quick_dirty',
        ],
      ),
      subscription: UserSubscription.free(),
    );
    _users[demoUser.id] = demoUser;

    // Also add Google/Apple mock users
    _users['google_user'] = demoUser.copyWith(
      id: 'google_user',
      email: 'alex@gmail.com',
      displayName: 'Alex G.',
    );
    _users['apple_user'] = demoUser.copyWith(
      id: 'apple_user',
      email: 'alex@icloud.com',
      displayName: 'Alex A.',
    );
  }

  Future<UserModel> createUser(String id, String name, String email) async {
    final user = UserModel(
      id: id,
      email: email,
      displayName: name,
      createdAt: DateTime.now(),
      onboarding: UserOnboarding.empty(),
      settings: UserSettings.defaults(),
      stats: UserStats.zero(),
      gamification: UserGamification.initial(),
      subscription: UserSubscription.free(),
    );
    _users[id] = user;
    return user;
  }

  Future<UserModel?> getUser(String id) async {
    return _users[id];
  }

  Future<UserModel> updateUser(UserModel user) async {
    _users[user.id] = user;
    return user;
  }

  Future<UserModel?> updateSettings(String userId, UserSettings settings) async {
    final user = _users[userId];
    if (user == null) return null;
    final updated = user.copyWith(settings: settings, updatedAt: DateTime.now());
    _users[userId] = updated;
    return updated;
  }

  Future<UserModel?> updateStats(String userId, UserStats stats) async {
    final user = _users[userId];
    if (user == null) return null;
    final updated = user.copyWith(stats: stats, updatedAt: DateTime.now());
    _users[userId] = updated;
    return updated;
  }

  Future<UserModel?> updateOnboarding(
      String userId, UserOnboarding onboarding) async {
    final user = _users[userId];
    if (user == null) return null;
    final updated = user.copyWith(
      onboarding: onboarding,
      updatedAt: DateTime.now(),
    );
    _users[userId] = updated;
    return updated;
  }

  Future<UserModel?> updateGamification(
      String userId, UserGamification gamification) async {
    final user = _users[userId];
    if (user == null) return null;
    final updated = user.copyWith(
      gamification: gamification,
      updatedAt: DateTime.now(),
    );
    _users[userId] = updated;
    return updated;
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());
