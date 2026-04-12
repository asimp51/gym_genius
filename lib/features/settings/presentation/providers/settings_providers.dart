import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Current user settings
final userSettingsProvider = Provider<UserSettings>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.settings ?? UserSettings.defaults();
});

// Weight unit
final weightUnitProvider = Provider<String>((ref) {
  return ref.watch(userSettingsProvider).weightUnit;
});

// Theme mode
final themeModeProvider = Provider<String>((ref) {
  return ref.watch(userSettingsProvider).theme;
});

// Rest timer default
final defaultRestTimerProvider = Provider<int>((ref) {
  return ref.watch(userSettingsProvider).restTimerSeconds;
});

// Notification settings
final notificationSettingsProvider = Provider<NotificationSettings>((ref) {
  return ref.watch(userSettingsProvider).notifications;
});

// Settings update actions
class SettingsNotifier extends StateNotifier<UserSettings> {
  final Ref _ref;

  SettingsNotifier(this._ref, UserSettings initial) : super(initial);

  void updateWeightUnit(String unit) {
    state = state.copyWith(weightUnit: unit);
    _ref.read(authProvider.notifier).updateSettings(state);
  }

  void updateDistanceUnit(String unit) {
    state = state.copyWith(distanceUnit: unit);
    _ref.read(authProvider.notifier).updateSettings(state);
  }

  void updateMeasurementUnit(String unit) {
    state = state.copyWith(measurementUnit: unit);
    _ref.read(authProvider.notifier).updateSettings(state);
  }

  void updateTheme(String theme) {
    state = state.copyWith(theme: theme);
    _ref.read(authProvider.notifier).updateSettings(state);
  }

  void updateRestTimer(int seconds) {
    state = state.copyWith(restTimerSeconds: seconds);
    _ref.read(authProvider.notifier).updateSettings(state);
  }

  void toggleWorkoutReminders(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(workoutReminders: value),
    );
    _ref.read(authProvider.notifier).updateSettings(state);
  }

  void toggleStreakReminders(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(streakReminders: value),
    );
    _ref.read(authProvider.notifier).updateSettings(state);
  }

  void toggleAiRecommendations(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(aiRecommendations: value),
    );
    _ref.read(authProvider.notifier).updateSettings(state);
  }

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
    _ref.read(authProvider.notifier).updateSettings(state);
  }

  void toggleSocialActivity(bool value) {
    state = state.copyWith(
      notifications: state.notifications.copyWith(socialActivity: value),
    );
    _ref.read(authProvider.notifier).updateSettings(state);
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final settings = ref.watch(userSettingsProvider);
  return SettingsNotifier(ref, settings);
});
