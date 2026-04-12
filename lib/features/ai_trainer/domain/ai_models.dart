class AiConversation {
  final String id;
  final String userId;
  final String type; // workout_generation, form_check, general
  final List<AiMessage> messages;
  final String? resultTemplateId;
  final DateTime createdAt;

  const AiConversation({
    required this.id,
    required this.userId,
    required this.type,
    required this.messages,
    this.resultTemplateId,
    required this.createdAt,
  });

  AiConversation copyWith({
    String? id,
    String? userId,
    String? type,
    List<AiMessage>? messages,
    String? resultTemplateId,
    DateTime? createdAt,
  }) {
    return AiConversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      messages: messages ?? this.messages,
      resultTemplateId: resultTemplateId ?? this.resultTemplateId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AiConversation.fromJson(Map<String, dynamic> json) {
    return AiConversation(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      messages: (json['messages'] as List)
          .map((e) => AiMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      resultTemplateId: json['resultTemplateId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'messages': messages.map((e) => e.toJson()).toList(),
        'resultTemplateId': resultTemplateId,
        'createdAt': createdAt.toIso8601String(),
      };
}

class AiMessage {
  final String role; // user, assistant
  final String content;
  final DateTime timestamp;

  const AiMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  AiMessage copyWith({
    String? role,
    String? content,
    DateTime? timestamp,
  }) {
    return AiMessage(
      role: role ?? this.role,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory AiMessage.fromJson(Map<String, dynamic> json) {
    return AiMessage(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };
}
