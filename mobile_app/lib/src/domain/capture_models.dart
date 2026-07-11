enum CaptureIntentType { todo, idea, todoDelete, unclear }

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

  Map<String, dynamic> toJson() {
    return {
      'start_at': startAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'location': location,
      'topic': topic,
      'reminder_at': reminderAt?.toIso8601String(),
      'status': status,
    };
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
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'source_hint': sourceHint,
      'tags': tags,
    };
  }
}

enum TodoDeleteOperation { delete, clear }

TodoDeleteOperation todoDeleteOperationFromJson(String value) {
  return TodoDeleteOperation.values.firstWhere(
    (operation) => operation.name == value,
    orElse: () => TodoDeleteOperation.delete,
  );
}

class TodoDeletePayload {
  const TodoDeletePayload({
    required this.operation,
    required this.dateFrom,
    required this.dateTo,
    required this.timeFrom,
    required this.timeTo,
    required this.keyword,
  });

  final TodoDeleteOperation operation;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final DateTime? timeFrom;
  final DateTime? timeTo;
  final String? keyword;

  factory TodoDeletePayload.fromJson(Map<String, dynamic> json) {
    return TodoDeletePayload(
      operation:
          todoDeleteOperationFromJson(json['operation'] as String? ?? 'delete'),
      dateFrom: _parseDate(json['date_from']),
      dateTo: _parseDate(json['date_to']),
      timeFrom: _parseDate(json['time_from']),
      timeTo: _parseDate(json['time_to']),
      keyword: json['keyword'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operation': operation.name,
      'date_from': dateFrom?.toIso8601String(),
      'date_to': dateTo?.toIso8601String(),
      'time_from': timeFrom?.toIso8601String(),
      'time_to': timeTo?.toIso8601String(),
      'keyword': keyword,
    };
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
    this.todoDeletePayload,
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
  final TodoDeletePayload? todoDeletePayload;

  factory CaptureResult.fromJson(Map<String, dynamic> json) {
    return CaptureResult(
      intentType: captureIntentTypeFromJson(
          json['intent_type'] as String? ?? 'unclear'),
      confidence: (json['confidence'] as num? ?? 0).toDouble(),
      title: json['title'] as String? ?? '未命名记录',
      summary: json['summary'] as String? ?? '',
      missingFields: (json['missing_fields'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      followUpQuestion: json['follow_up_question'] as String?,
      shouldSave: json['should_save'] as bool? ?? false,
      todoPayload: json['todo_payload'] is Map<String, dynamic>
          ? TodoPayload.fromJson(json['todo_payload'] as Map<String, dynamic>)
          : null,
      ideaPayload: json['idea_payload'] is Map<String, dynamic>
          ? IdeaPayload.fromJson(json['idea_payload'] as Map<String, dynamic>)
          : null,
      todoDeletePayload: json['todo_delete_payload'] is Map<String, dynamic>
          ? TodoDeletePayload.fromJson(
              json['todo_delete_payload'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intent_type': intentType.name,
      'confidence': confidence,
      'title': title,
      'summary': summary,
      'missing_fields': missingFields,
      'follow_up_question': followUpQuestion,
      'should_save': shouldSave,
      'todo_payload': todoPayload?.toJson(),
      'idea_payload': ideaPayload?.toJson(),
      'todo_delete_payload': todoDeletePayload?.toJson(),
    };
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toLocal();
}
