class ActiveWorkoutState {
  final String? templateId;
  final String? templateName;
  final String name;
  final DateTime startedAt;
  final List<ActiveExercise> exercises;
  final bool isActive;
  final bool isPaused;
  final int elapsedSeconds;
  final int currentExerciseIndex;
  final RestTimerState restTimer;

  const ActiveWorkoutState({
    this.templateId,
    this.templateName,
    required this.name,
    required this.startedAt,
    required this.exercises,
    this.isActive = true,
    this.isPaused = false,
    this.elapsedSeconds = 0,
    this.currentExerciseIndex = 0,
    this.restTimer = const RestTimerState(),
  });

  ActiveWorkoutState copyWith({
    String? templateId,
    String? templateName,
    String? name,
    DateTime? startedAt,
    List<ActiveExercise>? exercises,
    bool? isActive,
    bool? isPaused,
    int? elapsedSeconds,
    int? currentExerciseIndex,
    RestTimerState? restTimer,
  }) {
    return ActiveWorkoutState(
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      name: name ?? this.name,
      startedAt: startedAt ?? this.startedAt,
      exercises: exercises ?? this.exercises,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      restTimer: restTimer ?? this.restTimer,
    );
  }

  factory ActiveWorkoutState.fromJson(Map<String, dynamic> json) {
    return ActiveWorkoutState(
      templateId: json['templateId'] as String?,
      templateName: json['templateName'] as String?,
      name: json['name'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      exercises: (json['exercises'] as List)
          .map((e) => ActiveExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
      isPaused: json['isPaused'] as bool? ?? false,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      currentExerciseIndex: json['currentExerciseIndex'] as int? ?? 0,
      restTimer:
          RestTimerState.fromJson(json['restTimer'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'templateId': templateId,
        'templateName': templateName,
        'name': name,
        'startedAt': startedAt.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'isActive': isActive,
        'isPaused': isPaused,
        'elapsedSeconds': elapsedSeconds,
        'currentExerciseIndex': currentExerciseIndex,
        'restTimer': restTimer.toJson(),
      };

  factory ActiveWorkoutState.start({
    String? templateId,
    String? templateName,
    required String name,
  }) =>
      ActiveWorkoutState(
        name: name,
        templateId: templateId,
        templateName: templateName,
        startedAt: DateTime.now(),
        exercises: [],
        restTimer: const RestTimerState(),
      );

  factory ActiveWorkoutState.empty() => ActiveWorkoutState(
        name: '',
        startedAt: DateTime.now(),
        exercises: [],
        isActive: false,
        isPaused: false,
        elapsedSeconds: 0,
        currentExerciseIndex: 0,
        restTimer: const RestTimerState(),
      );
}

class ActiveExercise {
  final String exerciseId;
  final String exerciseName;
  final List<ActiveSet> sets;
  final bool isCompleted;
  final bool isExpanded;

  const ActiveExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    this.isCompleted = false,
    this.isExpanded = true,
  });

  ActiveExercise copyWith({
    String? exerciseId,
    String? exerciseName,
    List<ActiveSet>? sets,
    bool? isCompleted,
    bool? isExpanded,
  }) {
    return ActiveExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      sets: sets ?? this.sets,
      isCompleted: isCompleted ?? this.isCompleted,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  factory ActiveExercise.fromJson(Map<String, dynamic> json) {
    return ActiveExercise(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      sets: (json['sets'] as List)
          .map((e) => ActiveSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      isExpanded: json['isExpanded'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'sets': sets.map((e) => e.toJson()).toList(),
        'isCompleted': isCompleted,
        'isExpanded': isExpanded,
      };
}

class ActiveSet {
  final int setNumber;
  final double? weight;
  final int? reps;
  final double? rpe;
  final bool isWarmup;
  final bool isDropset;
  final bool isFailure;
  final bool isCompleted;
  final bool isPR;

  const ActiveSet({
    required this.setNumber,
    this.weight,
    this.reps,
    this.rpe,
    this.isWarmup = false,
    this.isDropset = false,
    this.isFailure = false,
    this.isCompleted = false,
    this.isPR = false,
  });

  ActiveSet copyWith({
    int? setNumber,
    double? weight,
    int? reps,
    double? rpe,
    bool? isWarmup,
    bool? isDropset,
    bool? isFailure,
    bool? isCompleted,
    bool? isPR,
  }) {
    return ActiveSet(
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      isWarmup: isWarmup ?? this.isWarmup,
      isDropset: isDropset ?? this.isDropset,
      isFailure: isFailure ?? this.isFailure,
      isCompleted: isCompleted ?? this.isCompleted,
      isPR: isPR ?? this.isPR,
    );
  }

  factory ActiveSet.fromJson(Map<String, dynamic> json) {
    return ActiveSet(
      setNumber: json['setNumber'] as int,
      weight: (json['weight'] as num?)?.toDouble(),
      reps: json['reps'] as int?,
      rpe: (json['rpe'] as num?)?.toDouble(),
      isWarmup: json['isWarmup'] as bool? ?? false,
      isDropset: json['isDropset'] as bool? ?? false,
      isFailure: json['isFailure'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isPR: json['isPR'] as bool? ?? false,
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
        'isCompleted': isCompleted,
        'isPR': isPR,
      };
}

class RestTimerState {
  final bool isRunning;
  final int remainingSeconds;
  final int totalSeconds;

  const RestTimerState({
    this.isRunning = false,
    this.remainingSeconds = 0,
    this.totalSeconds = 90,
  });

  RestTimerState copyWith({
    bool? isRunning,
    int? remainingSeconds,
    int? totalSeconds,
  }) {
    return RestTimerState(
      isRunning: isRunning ?? this.isRunning,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
    );
  }

  factory RestTimerState.fromJson(Map<String, dynamic> json) {
    return RestTimerState(
      isRunning: json['isRunning'] as bool? ?? false,
      remainingSeconds: json['remainingSeconds'] as int? ?? 0,
      totalSeconds: json['totalSeconds'] as int? ?? 90,
    );
  }

  Map<String, dynamic> toJson() => {
        'isRunning': isRunning,
        'remainingSeconds': remainingSeconds,
        'totalSeconds': totalSeconds,
      };
}
