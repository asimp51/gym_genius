import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/watch_communication_service.dart';
import '../../domain/health_models.dart';
import '../../../../services/wearable_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ---------------------------------------------------------------------------
// Core service providers
// ---------------------------------------------------------------------------

/// Singleton instance of the wearable service.
final wearableServiceProvider = Provider<WearableService>((ref) {
  final service = WearableService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Singleton instance of the watch communication service.
final watchCommunicationProvider =
    Provider<WatchCommunicationService>((ref) {
  final service = WatchCommunicationService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ---------------------------------------------------------------------------
// Health availability & permissions
// ---------------------------------------------------------------------------

/// Whether the health platform (Apple Health / Health Connect) is available.
final healthAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(wearableServiceProvider);
  return service.healthRepository.isAvailable();
});

/// Whether we have been granted health permissions.
/// Call `ref.refresh(healthPermissionProvider)` after requesting permissions.
final healthPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(wearableServiceProvider);
  return service.isConnected;
});

/// Request health permissions. Returns true if granted.
final requestHealthPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(wearableServiceProvider);
  final result = await service.connect();
  // Invalidate dependent providers so they re-fetch.
  ref.invalidate(healthPermissionProvider);
  ref.invalidate(todayHealthSummaryProvider);
  return result;
});

// ---------------------------------------------------------------------------
// Health data providers
// ---------------------------------------------------------------------------

/// Today's aggregated health summary (steps, calories, heart rate, etc.).
final todayHealthSummaryProvider =
    FutureProvider<HealthSummary>((ref) async {
  final service = ref.watch(wearableServiceProvider);
  if (!service.isConnected) return HealthSummary.empty();
  return service.refreshSummary();
});

/// Step count for today.
final stepsProvider = FutureProvider<int>((ref) async {
  final summary = await ref.watch(todayHealthSummaryProvider.future);
  return summary.steps;
});

/// Calories burned today.
final caloriesProvider = FutureProvider<double>((ref) async {
  final summary = await ref.watch(todayHealthSummaryProvider.future);
  return summary.caloriesBurned;
});

/// Last night's sleep data.
final sleepDataProvider = FutureProvider<SleepData?>((ref) async {
  final service = ref.watch(wearableServiceProvider);
  if (!service.isConnected) return null;
  return service.getSleepData();
});

/// Workout history from the health platform.
final healthWorkoutHistoryProvider =
    FutureProvider<List<HealthWorkout>>((ref) async {
  final service = ref.watch(wearableServiceProvider);
  if (!service.isConnected) return [];
  return service.getWorkoutHistory();
});

// ---------------------------------------------------------------------------
// Heart rate streaming (for active workout)
// ---------------------------------------------------------------------------

/// Real-time heart rate stream provider. Use during active workouts.
final heartRateStreamProvider = StreamProvider<int>((ref) {
  final service = ref.watch(wearableServiceProvider);
  if (!service.isConnected) return const Stream.empty();
  return service.startHeartRateMonitoring();
});

/// Current heart rate zone based on BPM and user age.
/// Defaults to age 30 — integrate with user profile for accuracy.
final heartRateZoneProvider =
    Provider.family<HeartRateZone, int>((ref, bpm) {
  final user = ref.watch(currentUserProvider);
  final userAge = user?.birthDate != null
      ? DateTime.now().difference(user!.birthDate!).inDays ~/ 365
      : 30;
  return HeartRateZone.currentZone(bpm, userAge);
});

// ---------------------------------------------------------------------------
// Connection state
// ---------------------------------------------------------------------------

/// Notifier that manages the wearable connection state for the UI.
class WearableConnectionNotifier extends AsyncNotifier<WearableConnectionState> {
  @override
  Future<WearableConnectionState> build() async {
    final wearable = ref.read(wearableServiceProvider);
    final watchComm = ref.read(watchCommunicationProvider);

    return WearableConnectionState(
      isHealthConnected: wearable.isConnected,
      isWatchConnected: watchComm.isWatchConnected,
      watchModel: watchComm.watchModel,
      lastSyncTime: wearable.lastSyncTime,
      autoSync: wearable.autoSync,
    );
  }

  Future<bool> connectHealth() async {
    final wearable = ref.read(wearableServiceProvider);
    final connected = await wearable.connect();
    state = AsyncData(state.value!.copyWith(
      isHealthConnected: connected,
      lastSyncTime: DateTime.now(),
    ));
    ref.invalidate(todayHealthSummaryProvider);
    return connected;
  }

  Future<void> initializeWatch() async {
    final watchComm = ref.read(watchCommunicationProvider);
    await watchComm.initialize();
    state = AsyncData(state.value!.copyWith(
      isWatchConnected: watchComm.isWatchConnected,
      watchModel: watchComm.watchModel,
    ));
  }

  void toggleAutoSync(bool enabled) {
    final wearable = ref.read(wearableServiceProvider);
    wearable.autoSync = enabled;
    state = AsyncData(state.value!.copyWith(autoSync: enabled));
  }

  Future<void> syncNow() async {
    final wearable = ref.read(wearableServiceProvider);
    await wearable.fullSync();
    state = AsyncData(state.value!.copyWith(
      lastSyncTime: DateTime.now(),
    ));
    ref.invalidate(todayHealthSummaryProvider);
  }
}

final wearableConnectionProvider = AsyncNotifierProvider<
    WearableConnectionNotifier, WearableConnectionState>(
  WearableConnectionNotifier.new,
);

class WearableConnectionState {
  final bool isHealthConnected;
  final bool isWatchConnected;
  final String? watchModel;
  final DateTime? lastSyncTime;
  final bool autoSync;

  const WearableConnectionState({
    this.isHealthConnected = false,
    this.isWatchConnected = false,
    this.watchModel,
    this.lastSyncTime,
    this.autoSync = true,
  });

  WearableConnectionState copyWith({
    bool? isHealthConnected,
    bool? isWatchConnected,
    String? watchModel,
    DateTime? lastSyncTime,
    bool? autoSync,
  }) {
    return WearableConnectionState(
      isHealthConnected: isHealthConnected ?? this.isHealthConnected,
      isWatchConnected: isWatchConnected ?? this.isWatchConnected,
      watchModel: watchModel ?? this.watchModel,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      autoSync: autoSync ?? this.autoSync,
    );
  }
}
