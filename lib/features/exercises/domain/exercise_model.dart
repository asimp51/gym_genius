class ExerciseModel {
  final String id;
  final String name;
  final String slug;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String category; // strength, cardio, stretching, plyometric
  final List<String> equipment;
  final String movementPattern; // push, pull, squat, hinge, carry, isolation
  final String difficulty; // beginner, intermediate, advanced
  final List<String> instructions;
  final List<String> tips;
  final String? thumbnailPath;
  final String? videoUrl;
  final bool isCompound;
  final List<String> searchTerms;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.category,
    required this.equipment,
    required this.movementPattern,
    required this.difficulty,
    required this.instructions,
    required this.tips,
    this.thumbnailPath,
    this.videoUrl,
    required this.isCompound,
    required this.searchTerms,
  });

  ExerciseModel copyWith({
    String? id,
    String? name,
    String? slug,
    List<String>? primaryMuscles,
    List<String>? secondaryMuscles,
    String? category,
    List<String>? equipment,
    String? movementPattern,
    String? difficulty,
    List<String>? instructions,
    List<String>? tips,
    String? thumbnailPath,
    String? videoUrl,
    bool? isCompound,
    List<String>? searchTerms,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      category: category ?? this.category,
      equipment: equipment ?? this.equipment,
      movementPattern: movementPattern ?? this.movementPattern,
      difficulty: difficulty ?? this.difficulty,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      videoUrl: videoUrl ?? this.videoUrl,
      isCompound: isCompound ?? this.isCompound,
      searchTerms: searchTerms ?? this.searchTerms,
    );
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      primaryMuscles: List<String>.from(json['primaryMuscles'] as List),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] as List),
      category: json['category'] as String,
      equipment: List<String>.from(json['equipment'] as List),
      movementPattern: json['movementPattern'] as String,
      difficulty: json['difficulty'] as String,
      instructions: List<String>.from(json['instructions'] as List),
      tips: List<String>.from(json['tips'] as List),
      thumbnailPath: json['thumbnailPath'] as String?,
      videoUrl: json['videoUrl'] as String?,
      isCompound: json['isCompound'] as bool,
      searchTerms: List<String>.from(json['searchTerms'] as List),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'primaryMuscles': primaryMuscles,
        'secondaryMuscles': secondaryMuscles,
        'category': category,
        'equipment': equipment,
        'movementPattern': movementPattern,
        'difficulty': difficulty,
        'instructions': instructions,
        'tips': tips,
        'thumbnailPath': thumbnailPath,
        'videoUrl': videoUrl,
        'isCompound': isCompound,
        'searchTerms': searchTerms,
      };
}

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  quads,
  hamstrings,
  glutes,
  calves,
  core,
  fullBody;

  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.quads:
        return 'Quads';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.fullBody:
        return 'Full Body';
    }
  }

  String get emoji {
    switch (this) {
      case MuscleGroup.chest:
        return '\u{1FAC1}';
      case MuscleGroup.back:
        return '\u{1F519}';
      case MuscleGroup.shoulders:
        return '\u{1F3D4}\u{FE0F}';
      case MuscleGroup.biceps:
        return '\u{1F4AA}';
      case MuscleGroup.triceps:
        return '\u{1F9BE}';
      case MuscleGroup.forearms:
        return '\u{1F91D}';
      case MuscleGroup.quads:
        return '\u{1F9B5}';
      case MuscleGroup.hamstrings:
        return '\u{1F9BF}';
      case MuscleGroup.glutes:
        return '\u{1F351}';
      case MuscleGroup.calves:
        return '\u{1F9B6}';
      case MuscleGroup.core:
        return '\u{1F3AF}';
      case MuscleGroup.fullBody:
        return '\u{1F3CB}\u{FE0F}';
    }
  }
}
