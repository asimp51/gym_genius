class WorkoutModel {
  final String id;
  final String userId;
  final String? templateId;
  final String? templateName;
  final String name;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int durationMinutes;
  final double totalVolume;
  final int totalSets;
  final int totalReps;
  final List<WorkoutExercise> exercises;
  final String? notes;
  final int? mood; // 1-5
  final List<PersonalRecordEntry> personalRecords;
  final String? aiRecommendation;
  final bool isPublic;

  const WorkoutModel({
    required this.id,
    required this.userId,
    this.templateId,
    this.templateName,
    required this.name,
    required this.startedAt,
    required this.finishedAt,
    required this.durationMinutes,
    required this.totalVolume,
    required this.totalSets,
    required this.totalReps,
    required this.exercises,
    this.notes,
    this.mood,
    required this.personalRecords,
    this.aiRecommendation,
    this.isPublic = false,
  });

  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? templateId,
    String? templateName,
    String? name,
    DateTime? startedAt,
    DateTime? finishedAt,
    int? durationMinutes,
    double? totalVolume,
    int? totalSets,
    int? totalReps,
    List<WorkoutExercise>? exercises,
    String? notes,
    int? mood,
    List<PersonalRecordEntry>? personalRecords,
    String? aiRecommendation,
    bool? isPublic,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      name: name ?? this.name,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      totalVolume: totalVolume ?? this.totalVolume,
      totalSets: totalSets ?? this.totalSets,
      totalReps: totalReps ?? this.totalReps,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      mood: mood ?? this.mood,
      personalRecords: personalRecords ?? this.personalRecords,
      aiRecommendation: aiRecommendation ?? this.aiRecommendation,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      templateId: json['templateId'] as String?,
      templateName: json['templateName'] as String?,
      name: json['name'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      finishedAt: DateTime.parse(json['finishedAt'] as String),
      durationMinutes: json['durationMinutes'] as int,
      totalVolume: (json['totalVolume'] as num).toDouble(),
      totalSets: json['totalSets'] as int,
      totalReps: json['totalReps'] as int,
      exercises: (json['exercises'] as List)
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      mood: json['mood'] as int?,
      personalRecords: (json['personalRecords'] as List)
          .map((e) => PersonalRecordEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      aiRecommendation: json['aiRecommendation'] as String?,
      isPublic: json['isPublic'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'templateId': templateId,
        'templateName': templateName,
        'name': name,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt.toIso8601String(),
        'durationMinutes': durationMinutes,
        'totalVolume': totalVolume,
        'totalSets': totalSets,
        'totalReps': totalReps,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'notes': notes,
        'mood': mood,
        'personalRecords': personalRecords.map((e) => e.toJson()).toList(),
        'aiRecommendation': aiRecommendation,
        'isPublic': isPublic,
      };
}

class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final int order;
  final List<WorkoutSet> sets;
  final String? notes;

  const WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.order,
    required this.sets,
    this.notes,
  });

  WorkoutExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    int? order,
    List<WorkoutSet>? sets,
    String? notes,
  }) {
    return WorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      order: order ?? this.order,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
    );
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      order: json['order'] as int,
      sets: (json['sets'] as List)
          .map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'order': order,
        'sets': sets.map((e) => e.toJson()).toList(),
        'notes': notes,
      };
}

class WorkoutSet {
  final int setNumber;
  final double weight;
  final int reps;
  final double? rpe;
  final bool isWarmup;
  final bool isDropset;
  final bool isFailure;
  final bool isPR;
  final bool isCompleted;
  final DateTime completedAt;
  final int? restDuration; // seconds

  const WorkoutSet({
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.rpe,
    this.isWarmup = false,
    this.isDropset = false,
    this.isFailure = false,
    this.isPR = false,
    this.isCompleted = true,
    required this.completedAt,
    this.restDuration,
  });

  WorkoutSet copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    double? rpe,
    bool? isWarmup,
    bool? isDropset,
    bool? isFailure,
    bool? isPR,
    bool? isCompleted,
    DateTime? completedAt,
    int? restDuration,
  }) {
    return WorkoutSet(
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      isWarmup: isWarmup ?? this.isWarmup,
      isDropset: isDropset ?? this.isDropset,
      isFailure: isFailure ?? this.isFailure,
      isPR: isPR ?? this.isPR,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      restDuration: restDuration ?? this.restDuration,
    );
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      setNumber: json['setNumber'] as int,
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'] as int,
      rpe: (json['rpe'] as num?)?.toDouble(),
      isWarmup: json['isWarmup'] as bool? ?? false,
      isDropset: json['isDropset'] as bool? ?? false,
      isFailure: json['isFailure'] as bool? ?? false,
      isPR: json['isPR'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? true,
      completedAt: DateTime.parse(json['completedAt'] as String),
      restDuration: json['restDuration'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'setNumber': setNumber,
        'weight': weight,
        'reps': reps,
        'rpe': rpe,
        'isWarmup': isWarmup,
        'isDropset': isDropset,
        'isFailure': isFailure,
        'isPR': isPR,
        'isCompleted': isCompleted,
        'completedAt': completedAt.toIso8601String(),
        'restDuration': restDuration,
      };
}

class PersonalRecordEntry {
  final String exerciseId;
  final String exerciseName;
  final String type; // weight, reps, volume, estimated1rm
  final double value;
  final double? previousValue;

  const PersonalRecordEntry({
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.value,
    this.previousValue,
  });

  PersonalRecordEntry copyWith({
    String? exerciseId,
    String? exerciseName,
    String? type,
    double? value,
    double? previousValue,
  }) {
    return PersonalRecordEntry(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      type: type ?? this.type,
      value: value ?? this.value,
      previousValue: previousValue ?? this.previousValue,
    );
  }

  factory PersonalRecordEntry.fromJson(Map<String, dynamic> json) {
    return PersonalRecordEntry(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      previousValue: (json['previousValue'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'type': type,
        'value': value,
        'previousValue': previousValue,
      };
}
