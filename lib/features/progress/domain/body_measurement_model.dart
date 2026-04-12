class BodyMeasurementModel {
  final String id;
  final DateTime date;
  final double? weight;
  final double? bodyFat;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? leftArm;
  final double? rightArm;
  final double? leftThigh;
  final double? rightThigh;
  final double? leftCalf;
  final double? rightCalf;
  final double? neck;
  final String? notes;
  final MeasurementPhotos photoUrls;

  const BodyMeasurementModel({
    required this.id,
    required this.date,
    this.weight,
    this.bodyFat,
    this.chest,
    this.waist,
    this.hips,
    this.leftArm,
    this.rightArm,
    this.leftThigh,
    this.rightThigh,
    this.leftCalf,
    this.rightCalf,
    this.neck,
    this.notes,
    this.photoUrls = const MeasurementPhotos(),
  });

  BodyMeasurementModel copyWith({
    String? id,
    DateTime? date,
    double? weight,
    double? bodyFat,
    double? chest,
    double? waist,
    double? hips,
    double? leftArm,
    double? rightArm,
    double? leftThigh,
    double? rightThigh,
    double? leftCalf,
    double? rightCalf,
    double? neck,
    String? notes,
    MeasurementPhotos? photoUrls,
  }) {
    return BodyMeasurementModel(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      bodyFat: bodyFat ?? this.bodyFat,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      leftArm: leftArm ?? this.leftArm,
      rightArm: rightArm ?? this.rightArm,
      leftThigh: leftThigh ?? this.leftThigh,
      rightThigh: rightThigh ?? this.rightThigh,
      leftCalf: leftCalf ?? this.leftCalf,
      rightCalf: rightCalf ?? this.rightCalf,
      neck: neck ?? this.neck,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }

  factory BodyMeasurementModel.fromJson(Map<String, dynamic> json) {
    return BodyMeasurementModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num?)?.toDouble(),
      bodyFat: (json['bodyFat'] as num?)?.toDouble(),
      chest: (json['chest'] as num?)?.toDouble(),
      waist: (json['waist'] as num?)?.toDouble(),
      hips: (json['hips'] as num?)?.toDouble(),
      leftArm: (json['leftArm'] as num?)?.toDouble(),
      rightArm: (json['rightArm'] as num?)?.toDouble(),
      leftThigh: (json['leftThigh'] as num?)?.toDouble(),
      rightThigh: (json['rightThigh'] as num?)?.toDouble(),
      leftCalf: (json['leftCalf'] as num?)?.toDouble(),
      rightCalf: (json['rightCalf'] as num?)?.toDouble(),
      neck: (json['neck'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      photoUrls: MeasurementPhotos.fromJson(
          json['photoUrls'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'weight': weight,
        'bodyFat': bodyFat,
        'chest': chest,
        'waist': waist,
        'hips': hips,
        'leftArm': leftArm,
        'rightArm': rightArm,
        'leftThigh': leftThigh,
        'rightThigh': rightThigh,
        'leftCalf': leftCalf,
        'rightCalf': rightCalf,
        'neck': neck,
        'notes': notes,
        'photoUrls': photoUrls.toJson(),
      };
}

class MeasurementPhotos {
  final String? front;
  final String? side;
  final String? back;

  const MeasurementPhotos({
    this.front,
    this.side,
    this.back,
  });

  MeasurementPhotos copyWith({
    String? front,
    String? side,
    String? back,
  }) {
    return MeasurementPhotos(
      front: front ?? this.front,
      side: side ?? this.side,
      back: back ?? this.back,
    );
  }

  factory MeasurementPhotos.fromJson(Map<String, dynamic> json) {
    return MeasurementPhotos(
      front: json['front'] as String?,
      side: json['side'] as String?,
      back: json['back'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'front': front,
        'side': side,
        'back': back,
      };
}
