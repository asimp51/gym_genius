import 'dart:io';
import 'package:health/health.dart';

/// Configuration for health data types and permissions.
///
/// Defines which health data types we request read/write access to
/// on each platform (Apple HealthKit / Android Health Connect).
class HealthConfig {
  HealthConfig._();

  /// Health data types we need to READ from the platform.
  static const List<HealthDataType> readTypes = [
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.TOTAL_CALORIES_BURNED,
    HealthDataType.WORKOUT,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.FLIGHTS_CLIMBED,
    HealthDataType.EXERCISE_TIME,
  ];

  /// Health data types we need to WRITE to the platform.
  static const List<HealthDataType> writeTypes = [
    HealthDataType.WORKOUT,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
  ];

  /// Build the list of [HealthDataAccess] permissions matching [readTypes]
  /// and [writeTypes].
  static List<HealthDataAccess> get permissions {
    final readPermissions =
        readTypes.map((_) => HealthDataAccess.READ).toList();
    final writePermissions =
        writeTypes.map((_) => HealthDataAccess.WRITE).toList();
    return [...readPermissions, ...writePermissions];
  }

  /// Combined list used when requesting authorisation.
  static List<HealthDataType> get allTypes => [...readTypes, ...writeTypes];

  /// User-facing descriptions for the permissions we request.
  static Map<String, String> get permissionDescriptions => {
        'Heart Rate':
            'Monitor your heart rate during workouts to track intensity and recovery.',
        'Steps': 'Track daily step count to measure overall activity.',
        'Calories':
            'Record calories burned during workouts and throughout the day.',
        'Workouts':
            'Save completed workouts to your health dashboard and read workout history.',
        'Sleep':
            'View sleep data to optimise recovery recommendations.',
        'Flights Climbed': 'Track elevation gain from your daily activity.',
      };

  /// Whether the current platform supports health integration.
  static bool get isPlatformSupported =>
      Platform.isIOS || Platform.isAndroid;

  /// Human-readable name for the current health platform.
  static String get platformName {
    if (Platform.isIOS) return 'Apple Health';
    if (Platform.isAndroid) return 'Health Connect';
    return 'Unknown';
  }
}
