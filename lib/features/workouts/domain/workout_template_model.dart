class WorkoutTemplateModel {
  final String id;
  final String? userId;
  final String name;
  final String? description;
  final List<String> targetMuscles;
  final int estimatedMinutes;
  final bool isSystem;
  final bool isAiGenerated;
  final List<TemplateExercise> exercises;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const WorkoutTemplateModel({
    required this.id,
    this.userId,
    required this.name,
    this.description,
    required this.targetMuscles,
    required this.estimatedMinutes,
    this.isSystem = false,
    this.isAiGenerated = false,
    required this.exercises,
    required this.createdAt,
    this.updatedAt,
  });

  WorkoutTemplateModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<String>? targetMuscles,
    int? estimatedMinutes,
    bool? isSystem,
    bool? isAiGenerated,
    List<TemplateExercise>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutTemplateModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      isSystem: isSystem ?? this.isSystem,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory WorkoutTemplateModel.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplateModel(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      targetMuscles: List<String>.from(json['targetMuscles'] as List),
      estimatedMinutes: json['estimatedMinutes'] as int,
      isSystem: json['isSystem'] as bool? ?? false,
      isAiGenerated: json['isAiGenerated'] as bool? ?? false,
      exercises: (json['exercises'] as List)
          .map((e) => TemplateExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'description': description,
        'targetMuscles': targetMuscles,
        'estimatedMinutes': estimatedMinutes,
        'isSystem': isSystem,
        'isAiGenerated': isAiGenerated,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

class TemplateExercise {
  final String exerciseId;
  final String exerciseName;
  final int order;
  final int targetSets;
  final String targetReps; // e.g. "8-12", "5", "12-15"
  final double? targetWeight;
  final String? notes;
  final int restSeconds;
  final int? supersetGroup;

  const TemplateExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.order,
    required this.targetSets,
    required this.targetReps,
    this.targetWeight,
    this.notes,
    this.restSeconds = 90,
    this.supersetGroup,
  });

  TemplateExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    int? order,
    int? targetSets,
    String? targetReps,
    double? targetWeight,
    String? notes,
    int? restSeconds,
    int? supersetGroup,
  }) {
    return TemplateExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      order: order ?? this.order,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetWeight: targetWeight ?? this.targetWeight,
      notes: notes ?? this.notes,
      restSeconds: restSeconds ?? this.restSeconds,
      supersetGroup: supersetGroup ?? this.supersetGroup,
    );
  }

  factory TemplateExercise.fromJson(Map<String, dynamic> json) {
    return TemplateExercise(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      order: json['order'] as int,
      targetSets: json['targetSets'] as int,
      targetReps: json['targetReps'] as String,
      targetWeight: (json['targetWeight'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      restSeconds: json['restSeconds'] as int? ?? 90,
      supersetGroup: json['supersetGroup'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'order': order,
        'targetSets': targetSets,
        'targetReps': targetReps,
        'targetWeight': targetWeight,
        'notes': notes,
        'restSeconds': restSeconds,
        'supersetGroup': supersetGroup,
      };
}
