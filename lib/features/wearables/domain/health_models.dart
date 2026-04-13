/// Health data models for wearable integration.
///
/// These models represent health and fitness data read from or written to
/// Apple HealthKit (iOS) and Health Connect (Android).
library;

enum HeartRateZoneType {
  rest,
  warmup,
  fatBurn,
  cardio,
  peak,
}

class HeartRateZone {
  final HeartRateZoneType zone;
  final int minBpm;
  final int maxBpm;
  final String label;

  const HeartRateZone({
    required this.zone,
    required this.minBpm,
    required this.maxBpm,
    required this.label,
  });

  /// Calculate heart rate zones based on user age using the standard
  /// percentage-of-max-heart-rate formula (220 - age).
  static List<HeartRateZone> zonesForAge(int age) {
    final maxHr = 220 - age;
    return [
      HeartRateZone(
        zone: HeartRateZoneType.rest,
        minBpm: 0,
        maxBpm: (maxHr * 0.50).round(),
        label: 'Rest',
      ),
      HeartRateZone(
        zone: HeartRateZoneType.warmup,
        minBpm: (maxHr * 0.50).round() + 1,
        maxBpm: (maxHr * 0.60).round(),
        label: 'Warm Up',
      ),
      HeartRateZone(
        zone: HeartRateZoneType.fatBurn,
        minBpm: (maxHr * 0.60).round() + 1,
        maxBpm: (maxHr * 0.70).round(),
        label: 'Fat Burn',
      ),
      HeartRateZone(
        zone: HeartRateZoneType.cardio,
        minBpm: (maxHr * 0.70).round() + 1,
        maxBpm: (maxHr * 0.85).round(),
        label: 'Cardio',
      ),
      HeartRateZone(
        zone: HeartRateZoneType.peak,
        minBpm: (maxHr * 0.85).round() + 1,
        maxBpm: maxHr,
        label: 'Peak',
      ),
    ];
  }

  /// Determine which zone a given BPM falls into.
  static HeartRateZone currentZone(int bpm, int age) {
    final zones = zonesForAge(age);
    for (final zone in zones.reversed) {
      if (bpm >= zone.minBpm) return zone;
    }
    return zones.first;
  }

  Map<String, dynamic> toJson() => {
        'zone': zone.name,
        'minBpm': minBpm,
        'maxBpm': maxBpm,
        'label': label,
      };
}

class HealthSummary {
  final int steps;
  final double caloriesBurned;
  final int activeMinutes;
  final int? currentHeartRate;
  final int? restingHeartRate;
  final int? maxHeartRate;
  final int? floorsClimbed;
  final DateTime timestamp;

  const HealthSummary({
    required this.steps,
    required this.caloriesBurned,
    required this.activeMinutes,
    this.currentHeartRate,
    this.restingHeartRate,
    this.maxHeartRate,
    this.floorsClimbed,
    required this.timestamp,
  });

  factory HealthSummary.empty() => HealthSummary(
        steps: 0,
        caloriesBurned: 0,
        activeMinutes: 0,
        timestamp: DateTime.now(),
      );

  HealthSummary copyWith({
    int? steps,
    double? caloriesBurned,
    int? activeMinutes,
    int? currentHeartRate,
    int? restingHeartRate,
    int? maxHeartRate,
    int? floorsClimbed,
    DateTime? timestamp,
  }) {
    return HealthSummary(
      steps: steps ?? this.steps,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      currentHeartRate: currentHeartRate ?? this.currentHeartRate,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      floorsClimbed: floorsClimbed ?? this.floorsClimbed,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory HealthSummary.fromJson(Map<String, dynamic> json) {
    return HealthSummary(
      steps: json['steps'] as int? ?? 0,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toDouble() ?? 0,
      activeMinutes: json['activeMinutes'] as int? ?? 0,
      currentHeartRate: json['currentHeartRate'] as int?,
      restingHeartRate: json['restingHeartRate'] as int?,
      maxHeartRate: json['maxHeartRate'] as int?,
      floorsClimbed: json['floorsClimbed'] as int?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'steps': steps,
        'caloriesBurned': caloriesBurned,
        'activeMinutes': activeMinutes,
        'currentHeartRate': currentHeartRate,
        'restingHeartRate': restingHeartRate,
        'maxHeartRate': maxHeartRate,
        'floorsClimbed': floorsClimbed,
        'timestamp': timestamp.toIso8601String(),
      };
}

class HealthWorkout {
  final String id;
  final String type; // strength, cardio, hiit, yoga, etc.
  final DateTime startTime;
  final DateTime endTime;
  final double calories;
  final int? heartRateAvg;
  final int? heartRateMax;
  final String source; // "Apple Watch", "Wear OS", "GymGenius"

  const HealthWorkout({
    required this.id,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.calories,
    this.heartRateAvg,
    this.heartRateMax,
    required this.source,
  });

  Duration get duration => endTime.difference(startTime);

  factory HealthWorkout.fromJson(Map<String, dynamic> json) {
    return HealthWorkout(
      id: json['id'] as String,
      type: json['type'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      calories: (json['calories'] as num).toDouble(),
      heartRateAvg: json['heartRateAvg'] as int?,
      heartRateMax: json['heartRateMax'] as int?,
      source: json['source'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'calories': calories,
        'heartRateAvg': heartRateAvg,
        'heartRateMax': heartRateMax,
        'source': source,
      };
}

class WorkoutHealthData {
  final String workoutName;
  final String workoutType;
  final DateTime startTime;
  final DateTime endTime;
  final double totalCalories;
  final double totalVolume;
  final int totalSets;
  final int totalReps;
  final List<int> heartRateSamples;

  const WorkoutHealthData({
    required this.workoutName,
    required this.workoutType,
    required this.startTime,
    required this.endTime,
    required this.totalCalories,
    required this.totalVolume,
    required this.totalSets,
    required this.totalReps,
    this.heartRateSamples = const [],
  });

  int? get avgHeartRate {
    if (heartRateSamples.isEmpty) return null;
    return (heartRateSamples.reduce((a, b) => a + b) /
            heartRateSamples.length)
        .round();
  }

  int? get maxHeartRate {
    if (heartRateSamples.isEmpty) return null;
    return heartRateSamples.reduce((a, b) => a > b ? a : b);
  }

  Map<String, dynamic> toJson() => {
        'workoutName': workoutName,
        'workoutType': workoutType,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'totalCalories': totalCalories,
        'totalVolume': totalVolume,
        'totalSets': totalSets,
        'totalReps': totalReps,
        'heartRateSamples': heartRateSamples,
      };
}

class SleepData {
  final Duration totalDuration;
  final double quality; // 0.0 - 1.0
  final DateTime bedTime;
  final DateTime wakeTime;
  final Duration? deepSleep;
  final Duration? lightSleep;
  final Duration? remSleep;

  const SleepData({
    required this.totalDuration,
    required this.quality,
    required this.bedTime,
    required this.wakeTime,
    this.deepSleep,
    this.lightSleep,
    this.remSleep,
  });

  String get qualityLabel {
    if (quality >= 0.8) return 'Excellent';
    if (quality >= 0.6) return 'Good';
    if (quality >= 0.4) return 'Fair';
    return 'Poor';
  }

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      totalDuration: Duration(minutes: json['totalDurationMinutes'] as int),
      quality: (json['quality'] as num).toDouble(),
      bedTime: DateTime.parse(json['bedTime'] as String),
      wakeTime: DateTime.parse(json['wakeTime'] as String),
      deepSleep: json['deepSleepMinutes'] != null
          ? Duration(minutes: json['deepSleepMinutes'] as int)
          : null,
      lightSleep: json['lightSleepMinutes'] != null
          ? Duration(minutes: json['lightSleepMinutes'] as int)
          : null,
      remSleep: json['remSleepMinutes'] != null
          ? Duration(minutes: json['remSleepMinutes'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalDurationMinutes': totalDuration.inMinutes,
        'quality': quality,
        'bedTime': bedTime.toIso8601String(),
        'wakeTime': wakeTime.toIso8601String(),
        'deepSleepMinutes': deepSleep?.inMinutes,
        'lightSleepMinutes': lightSleep?.inMinutes,
        'remSleepMinutes': remSleep?.inMinutes,
      };
}
