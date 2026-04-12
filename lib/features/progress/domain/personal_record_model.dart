class PersonalRecordModel {
  final String exerciseId;
  final String exerciseName;
  final RecordEntry? maxWeight;
  final RepRecordEntry? maxReps;
  final RecordEntry? maxVolume;
  final RecordEntry? estimated1rm;

  const PersonalRecordModel({
    required this.exerciseId,
    required this.exerciseName,
    this.maxWeight,
    this.maxReps,
    this.maxVolume,
    this.estimated1rm,
  });

  PersonalRecordModel copyWith({
    String? exerciseId,
    String? exerciseName,
    RecordEntry? maxWeight,
    RepRecordEntry? maxReps,
    RecordEntry? maxVolume,
    RecordEntry? estimated1rm,
  }) {
    return PersonalRecordModel(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      maxWeight: maxWeight ?? this.maxWeight,
      maxReps: maxReps ?? this.maxReps,
      maxVolume: maxVolume ?? this.maxVolume,
      estimated1rm: estimated1rm ?? this.estimated1rm,
    );
  }

  factory PersonalRecordModel.fromJson(Map<String, dynamic> json) {
    return PersonalRecordModel(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      maxWeight: json['maxWeight'] != null
          ? RecordEntry.fromJson(json['maxWeight'] as Map<String, dynamic>)
          : null,
      maxReps: json['maxReps'] != null
          ? RepRecordEntry.fromJson(json['maxReps'] as Map<String, dynamic>)
          : null,
      maxVolume: json['maxVolume'] != null
          ? RecordEntry.fromJson(json['maxVolume'] as Map<String, dynamic>)
          : null,
      estimated1rm: json['estimated1rm'] != null
          ? RecordEntry.fromJson(json['estimated1rm'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'maxWeight': maxWeight?.toJson(),
        'maxReps': maxReps?.toJson(),
        'maxVolume': maxVolume?.toJson(),
        'estimated1rm': estimated1rm?.toJson(),
      };
}

class RecordEntry {
  final double value;
  final DateTime date;
  final String workoutId;

  const RecordEntry({
    required this.value,
    required this.date,
    required this.workoutId,
  });

  RecordEntry copyWith({
    double? value,
    DateTime? date,
    String? workoutId,
  }) {
    return RecordEntry(
      value: value ?? this.value,
      date: date ?? this.date,
      workoutId: workoutId ?? this.workoutId,
    );
  }

  factory RecordEntry.fromJson(Map<String, dynamic> json) {
    return RecordEntry(
      value: (json['value'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      workoutId: json['workoutId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'date': date.toIso8601String(),
        'workoutId': workoutId,
      };
}

class RepRecordEntry {
  final int value;
  final double weight;
  final DateTime date;
  final String workoutId;

  const RepRecordEntry({
    required this.value,
    required this.weight,
    required this.date,
    required this.workoutId,
  });

  RepRecordEntry copyWith({
    int? value,
    double? weight,
    DateTime? date,
    String? workoutId,
  }) {
    return RepRecordEntry(
      value: value ?? this.value,
      weight: weight ?? this.weight,
      date: date ?? this.date,
      workoutId: workoutId ?? this.workoutId,
    );
  }

  factory RepRecordEntry.fromJson(Map<String, dynamic> json) {
    return RepRecordEntry(
      value: json['value'] as int,
      weight: (json['weight'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      workoutId: json['workoutId'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'weight': weight,
        'date': date.toIso8601String(),
        'workoutId': workoutId,
      };
}
