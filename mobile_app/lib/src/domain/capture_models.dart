enum CaptureIntentType { todo, idea, unclear }

CaptureIntentType captureIntentTypeFromJson(String value) {
  return CaptureIntentType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => CaptureIntentType.unclear,
  );
}

class TodoPayload {
  const TodoPayload({
    required this.startAt,
    required this.endAt,
    required this.location,
    required this.topic,
    required this.reminderAt,
    required this.status,
  });

  final DateTime? startAt;
  final DateTime? endAt;
  final String? location;
  final String? topic;
  final DateTime? reminderAt;
  final String status;

  factory TodoPayload.fromJson(Map<String, dynamic> json) {
    return TodoPayload(
      startAt: _parseDate(json['start_at']),
      endAt: _parseDate(json['end_at']),
      location: json['location'] as String?,
      topic: json['topic'] as String?,
      reminderAt: _parseDate(json['reminder_at']),
      status: json['status'] as String? ?? 'draft',
    );
  }
}

class IdeaPayload {
  const IdeaPayload({
    required this.summary,
    required this.sourceHint,
    required this.tags,
  });

  final String summary;
  final String? sourceHint;
  final List<String> tags;

  factory IdeaPayload.fromJson(Map<String, dynamic> json) {
    return IdeaPayload(
      summary: json['summary'] as String? ?? '',
      sourceHint: json['source_hint'] as String?,
      tags: (json['tags'] as List<dynamic>? ?? const []).map((item) => item.toString()).toList(),
    );
  }
}

class CaptureResult {
  const CaptureResult({
    required this.intentType,
    required this.confidence,
    required this.title,
    required this.summary,
    required this.missingFields,
    required this.followUpQuestion,
    required this.shouldSave,
    required this.todoPayload,
    required this.ideaPayload,
  });

  final CaptureIntentType intentType;
  final double confidence;
  final String title;
  final String summary;
  final List<String> missingFields;
  final String? followUpQuestion;
  final bool shouldSave;
  final TodoPayload? todoPayload;
  final IdeaPayload? ideaPayload;

  factory CaptureResult.fromJson(Map<String, dynamic> json) {
    return CaptureResult(
      intentType: captureIntentTypeFromJson(json['intent_type'] as String? ?? 'unclear'),
      confidence: (json['confidence'] as num? ?? 0).toDouble(),
      title: json['title'] as String? ?? '未命名记录',
      summary: json['summary'] as String? ?? '',
      missingFields: (json['missing_fields'] as List<dynamic>? ?? const []).map((item) => item.toString()).toList(),
      followUpQuestion: json['follow_up_question'] as String?,
      shouldSave: json['should_save'] as bool? ?? false,
      todoPayload: json['todo_payload'] is Map<String, dynamic>
          ? TodoPayload.fromJson(json['todo_payload'] as Map<String, dynamic>)
          : null,
      ideaPayload: json['idea_payload'] is Map<String, dynamic>
          ? IdeaPayload.fromJson(json['idea_payload'] as Map<String, dynamic>)
          : null,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}
