class SocialPost {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String type; // workout_summary, pr, badge, streak, photo
  final String? workoutId;
  final String? content;
  final PostStats stats;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final bool isLikedByMe;

  const SocialPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.type,
    this.workoutId,
    this.content,
    this.stats = const PostStats(),
    this.imageUrl,
    this.likeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.isLikedByMe = false,
  });

  SocialPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? type,
    String? workoutId,
    String? content,
    PostStats? stats,
    String? imageUrl,
    int? likeCount,
    int? commentCount,
    DateTime? createdAt,
    bool? isLikedByMe,
  }) {
    return SocialPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      type: type ?? this.type,
      workoutId: workoutId ?? this.workoutId,
      content: content ?? this.content,
      stats: stats ?? this.stats,
      imageUrl: imageUrl ?? this.imageUrl,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String?,
      type: json['type'] as String,
      workoutId: json['workoutId'] as String?,
      content: json['content'] as String?,
      stats: PostStats.fromJson(json['stats'] as Map<String, dynamic>),
      imageUrl: json['imageUrl'] as String?,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isLikedByMe: json['isLikedByMe'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userPhotoUrl': userPhotoUrl,
        'type': type,
        'workoutId': workoutId,
        'content': content,
        'stats': stats.toJson(),
        'imageUrl': imageUrl,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'createdAt': createdAt.toIso8601String(),
        'isLikedByMe': isLikedByMe,
      };
}

class PostStats {
  final int? duration; // minutes
  final int? exercises;
  final double? volume;
  final int? prs;

  const PostStats({
    this.duration,
    this.exercises,
    this.volume,
    this.prs,
  });

  PostStats copyWith({
    int? duration,
    int? exercises,
    double? volume,
    int? prs,
  }) {
    return PostStats(
      duration: duration ?? this.duration,
      exercises: exercises ?? this.exercises,
      volume: volume ?? this.volume,
      prs: prs ?? this.prs,
    );
  }

  factory PostStats.fromJson(Map<String, dynamic> json) {
    return PostStats(
      duration: json['duration'] as int?,
      exercises: json['exercises'] as int?,
      volume: (json['volume'] as num?)?.toDouble(),
      prs: json['prs'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'duration': duration,
        'exercises': exercises,
        'volume': volume,
        'prs': prs,
      };
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.text,
    required this.createdAt,
  });

  Comment copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? text,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String?,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userPhotoUrl': userPhotoUrl,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };
}
