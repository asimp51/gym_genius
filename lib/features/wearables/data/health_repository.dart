import 'dart:async';
import 'dart:io';
import 'package:health/health.dart';
import '../config/health_config.dart';
import '../domain/health_models.dart';

/// Repository that wraps the `health` package to provide a clean API
/// for reading/writing health data from Apple HealthKit (iOS) and
/// Health Connect (Android).
class HealthRepository {
  final Health _health = Health();

  bool _isAuthorised = false;
  DateTime? _lastSyncTime;

  /// Timestamp of last successful data sync.
  DateTime? get lastSyncTime => _lastSyncTime;

  // ---------------------------------------------------------------------------
  // Availability & Permissions
  // ---------------------------------------------------------------------------

  /// Check whether the health platform is available on this device.
  Future<bool> isAvailable() async {
    if (!HealthConfig.isPlatformSupported) return false;
    try {
      final status = await _health.getHealthConnectSdkStatus();
      if (Platform.isAndroid) {
        return status == HealthConnectSdkStatus.sdkAvailable;
      }
      // iOS always has HealthKit available on iPhone/Watch.
      return true;
    } catch (_) {
      // On iOS getHealthConnectSdkStatus throws; HealthKit is always present.
      if (Platform.isIOS) return true;
      return false;
    }
  }

  /// Request permissions for all configured health data types.
  /// Returns `true` if the user granted permissions.
  Future<bool> requestPermissions() async {
    try {
      _isAuthorised = await _health.requestAuthorization(
        HealthConfig.allTypes,
        permissions: HealthConfig.permissions,
      );
      return _isAuthorised;
    } catch (e) {
      _isAuthorised = false;
      return false;
    }
  }

  /// Whether we currently have authorisation.
  bool get isAuthorised => _isAuthorised;

  // ---------------------------------------------------------------------------
  // Read — Today's Summary
  // ---------------------------------------------------------------------------

  /// Fetch an aggregated summary of today's health data.
  Future<HealthSummary> getTodaysSummary() async {
    if (!_isAuthorised) return HealthSummary.empty();

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      final steps = await getSteps(date: now);
      final calories = await getCaloriesBurned(date: now);
      final heartRate = await _getLatestHeartRate(midnight, now);
      final restingHr = await getRestingHeartRate();

      int activeMinutes = 0;
      try {
        final exerciseData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.EXERCISE_TIME],
          startTime: midnight,
          endTime: now,
        );
        for (final dp in exerciseData) {
          if (dp.value is NumericHealthValue) {
            activeMinutes +=
                (dp.value as NumericHealthValue).numericValue.toInt();
          }
        }
      } catch (_) {}

      _lastSyncTime = DateTime.now();

      return HealthSummary(
        steps: steps,
        caloriesBurned: calories,
        activeMinutes: activeMinutes,
        currentHeartRate: heartRate,
        restingHeartRate: restingHr,
        floorsClimbed: await _getFlightsClimbed(midnight, now),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return HealthSummary.empty();
    }
  }

  // ---------------------------------------------------------------------------
  // Read — Heart Rate
  // ---------------------------------------------------------------------------

  /// Stream that emits heart rate values. During an active workout, this
  /// polls the health platform at a configurable interval.
  Stream<int> getHeartRateStream({
    Duration interval = const Duration(seconds: 5),
  }) {
    late StreamController<int> controller;
    Timer? timer;

    controller = StreamController<int>(
      onListen: () {
        timer = Timer.periodic(interval, (_) async {
          final now = DateTime.now();
          final start = now.subtract(interval * 2);
          final hr = await _getLatestHeartRate(start, now);
          if (hr != null && !controller.isClosed) {
            controller.add(hr);
          }
        });
      },
      onCancel: () {
        timer?.cancel();
        controller.close();
      },
    );

    return controller.stream;
  }

  /// Get the resting heart rate for today.
  Future<int?> getRestingHeartRate() async {
    if (!_isAuthorised) return null;
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.RESTING_HEART_RATE],
        startTime: midnight,
        endTime: now,
      );
      if (data.isEmpty) return null;
      final latest = data.last;
      if (latest.value is NumericHealthValue) {
        return (latest.value as NumericHealthValue).numericValue.toInt();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Read — Steps
  // ---------------------------------------------------------------------------

  /// Get step count for a given [date] (defaults to today).
  Future<int> getSteps({DateTime? date}) async {
    if (!_isAuthorised) return 0;
    final target = date ?? DateTime.now();
    final midnight = DateTime(target.year, target.month, target.day);
    final endOfDay = midnight.add(const Duration(days: 1));
    try {
      final steps = await _health.getTotalStepsInInterval(
        midnight,
        endOfDay,
      );
      return steps ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ---------------------------------------------------------------------------
  // Read — Calories
  // ---------------------------------------------------------------------------

  /// Get calories burned for a given [date] (defaults to today).
  Future<double> getCaloriesBurned({DateTime? date}) async {
    if (!_isAuthorised) return 0;
    final target = date ?? DateTime.now();
    final midnight = DateTime(target.year, target.month, target.day);
    final endOfDay = midnight.add(const Duration(days: 1));
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: midnight,
        endTime: endOfDay,
      );
      double total = 0;
      for (final dp in data) {
        if (dp.value is NumericHealthValue) {
          total += (dp.value as NumericHealthValue).numericValue.toDouble();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  // ---------------------------------------------------------------------------
  // Write — Workout
  // ---------------------------------------------------------------------------

  /// Write a completed workout session to the health platform.
  Future<void> saveWorkout(WorkoutHealthData data) async {
    if (!_isAuthorised) return;

    try {
      await _health.writeWorkoutData(
        activityType: _mapWorkoutType(data.workoutType),
        start: data.startTime,
        end: data.endTime,
        totalEnergyBurned: data.totalCalories.round(),
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
      );

      // Write active energy burned data point as well.
      if (data.totalCalories > 0) {
        await _health.writeHealthData(
          value: data.totalCalories,
          type: HealthDataType.ACTIVE_ENERGY_BURNED,
          startTime: data.startTime,
          endTime: data.endTime,
          unit: HealthDataUnit.KILOCALORIE,
        );
      }
    } catch (_) {
      // Silently fail — workout still saved locally.
    }
  }

  // ---------------------------------------------------------------------------
  // Read — Workout History
  // ---------------------------------------------------------------------------

  /// Get workout history from the health platform for the last [days] days.
  Future<List<HealthWorkout>> getWorkoutHistory({int days = 30}) async {
    if (!_isAuthorised) return [];
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: start,
        endTime: now,
      );
      return data.map((dp) {
        return HealthWorkout(
          id: dp.hashCode.toString(),
          type: dp.type.name,
          startTime: dp.dateFrom,
          endTime: dp.dateTo,
          calories: dp.value is NumericHealthValue
              ? (dp.value as NumericHealthValue).numericValue.toDouble()
              : 0,
          source: dp.sourceName,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Read — Sleep
  // ---------------------------------------------------------------------------

  /// Get last night's sleep data.
  Future<SleepData?> getLastNightSleep() async {
    if (!_isAuthorised) return null;
    final now = DateTime.now();
    // Look back 24 hours for the most recent sleep session.
    final start = now.subtract(const Duration(hours: 24));
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_SESSION],
        startTime: start,
        endTime: now,
      );
      if (data.isEmpty) return null;
      final latest = data.last;
      final duration = latest.dateTo.difference(latest.dateFrom);
      return SleepData(
        totalDuration: duration,
        quality: _estimateSleepQuality(duration),
        bedTime: latest.dateFrom,
        wakeTime: latest.dateTo,
      );
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Private Helpers
  // ---------------------------------------------------------------------------

  Future<int?> _getLatestHeartRate(DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      );
      if (data.isEmpty) return null;
      final latest = data.last;
      if (latest.value is NumericHealthValue) {
        return (latest.value as NumericHealthValue).numericValue.toInt();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<int?> _getFlightsClimbed(DateTime start, DateTime end) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.FLIGHTS_CLIMBED],
        startTime: start,
        endTime: end,
      );
      int total = 0;
      for (final dp in data) {
        if (dp.value is NumericHealthValue) {
          total += (dp.value as NumericHealthValue).numericValue.toInt();
        }
      }
      return total > 0 ? total : null;
    } catch (_) {
      return null;
    }
  }

  HealthWorkoutActivityType _mapWorkoutType(String type) {
    switch (type.toLowerCase()) {
      case 'strength':
      case 'weight_training':
        return HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING;
      case 'cardio':
      case 'running':
        return HealthWorkoutActivityType.RUNNING;
      case 'hiit':
        return HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING;
      case 'yoga':
        return HealthWorkoutActivityType.YOGA;
      case 'cycling':
        return HealthWorkoutActivityType.BIKING;
      case 'swimming':
        return HealthWorkoutActivityType.SWIMMING;
      default:
        return HealthWorkoutActivityType.OTHER;
    }
  }

  double _estimateSleepQuality(Duration duration) {
    // Simple heuristic: 7-9 hours is ideal.
    final hours = duration.inMinutes / 60.0;
    if (hours >= 7 && hours <= 9) return 0.85;
    if (hours >= 6 && hours < 7) return 0.65;
    if (hours > 9 && hours <= 10) return 0.70;
    if (hours >= 5 && hours < 6) return 0.45;
    return 0.30;
  }
}
