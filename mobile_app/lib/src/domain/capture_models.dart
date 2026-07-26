enum CaptureIntentType { todo, idea, ledger, todoDelete, todoQuery, unclear }

CaptureIntentType captureIntentTypeFromJson(String value) {
  return CaptureIntentType.values.firstWhere(
    (type) => type.name == value,
    orElse: () => CaptureIntentType.unclear,
  );
}

enum InteractionMode { newRequest, supplement, correction, query }

InteractionMode interactionModeFromJson(String value) {
  return InteractionMode.values.firstWhere(
    (mode) => mode.name == value,
    orElse: () => InteractionMode.newRequest,
  );
}

class TodoPayload {
  const TodoPayload({
    this.title,
    this.summary,
    required this.startAt,
    required this.endAt,
    required this.location,
    required this.topic,
    required this.reminderAt,
    required this.status,
    this.durationMinutes,
  });

  final String? title;
  final String? summary;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? location;
  final String? topic;
  final DateTime? reminderAt;
  final String status;
  final int? durationMinutes;

  TodoPayload copyWith({
    String? title,
    String? summary,
    DateTime? startAt,
    DateTime? endAt,
    String? location,
    String? topic,
    DateTime? reminderAt,
    String? status,
    int? durationMinutes,
    bool clearLocation = false,
    bool clearTopic = false,
    bool clearReminderAt = false,
  }) {
    return TodoPayload(
      title: title ?? this.title,
      summary: summary ?? this.summary,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      location: clearLocation ? null : (location ?? this.location),
      topic: clearTopic ? null : (topic ?? this.topic),
      reminderAt: clearReminderAt ? null : (reminderAt ?? this.reminderAt),
      status: status ?? this.status,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  factory TodoPayload.fromJson(Map<String, dynamic> json) {
    return TodoPayload(
      title: json['title'] as String?,
      summary: json['summary'] as String?,
      startAt: _parseDate(json['start_at']),
      endAt: _parseDate(json['end_at']),
      location: json['location'] as String?,
      topic: json['topic'] as String?,
      reminderAt: _parseDate(json['reminder_at']),
      status: json['status'] as String? ?? 'draft',
      durationMinutes: json['duration_minutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      'start_at': startAt?.toIso8601String(),
      'end_at': endAt?.toIso8601String(),
      'location': location,
      'topic': topic,
      'reminder_at': reminderAt?.toIso8601String(),
      'status': status,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
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

class LedgerPayload {
  const LedgerPayload({
    required this.direction,
    required this.amountCents,
    required this.categoryCode,
    required this.note,
    required this.occurredAt,
  });

  final String direction;
  final int amountCents;
  final String categoryCode;
  final String note;
  final DateTime? occurredAt;

  factory LedgerPayload.fromJson(Map<String, dynamic> json) => LedgerPayload(
        direction: json['direction'] as String? ?? 'expense',
        amountCents: json['amount_cents'] as int? ?? 0,
        categoryCode: json['category_code'] as String? ?? 'other_expense',
        note: json['note'] as String? ?? '',
        occurredAt: _parseDate(json['occurred_at']),
      );

  Map<String, dynamic> toJson() => {
        'direction': direction,
        'amount_cents': amountCents,
        'category_code': categoryCode,
        'note': note,
        'occurred_at': occurredAt?.toIso8601String(),
      };
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

class TodoQueryPayload {
  const TodoQueryPayload({
    this.dateFrom,
    this.dateTo,
    this.keyword,
    this.includeCompleted = false,
    this.importanceRequested = false,
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? keyword;
  final bool includeCompleted;
  final bool importanceRequested;

  factory TodoQueryPayload.fromJson(Map<String, dynamic> json) {
    return TodoQueryPayload(
      dateFrom: _parseDate(json['date_from']),
      dateTo: _parseDate(json['date_to']),
      keyword: json['keyword'] as String?,
      includeCompleted: json['include_completed'] as bool? ?? false,
      importanceRequested: json['importance_requested'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_from': dateFrom?.toIso8601String(),
      'date_to': dateTo?.toIso8601String(),
      'keyword': keyword,
      'include_completed': includeCompleted,
      'importance_requested': importanceRequested,
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
    this.todoPayloads = const [],
    this.ledgerPayload,
    this.todoDeletePayload,
    this.todoQueryPayload,
    this.interactionMode,
    this.updatedFields = const [],
  });

  final CaptureIntentType intentType;
  final double confidence;
  final String title;
  final String summary;
  final List<String> missingFields;
  final String? followUpQuestion;
  final bool shouldSave;
  final TodoPayload? todoPayload;
  final List<TodoPayload> todoPayloads;
  final LedgerPayload? ledgerPayload;
  final IdeaPayload? ideaPayload;
  final TodoDeletePayload? todoDeletePayload;
  final TodoQueryPayload? todoQueryPayload;
  final InteractionMode? interactionMode;
  final List<String> updatedFields;

  List<TodoPayload> get effectiveTodoPayloads {
    if (todoPayloads.isNotEmpty) {
      return todoPayloads;
    }
    final single = todoPayload;
    return single == null ? const [] : [single];
  }

  factory CaptureResult.fromJson(Map<String, dynamic> json) {
    final todoPayload = json['todo_payload'] is Map<String, dynamic>
        ? TodoPayload.fromJson(json['todo_payload'] as Map<String, dynamic>)
        : null;
    final todoPayloads = (json['todo_payloads'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TodoPayload.fromJson)
        .toList(growable: false);
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
      todoPayload:
          todoPayload ?? (todoPayloads.isEmpty ? null : todoPayloads.first),
      todoPayloads: todoPayloads,
      ledgerPayload: json['ledger_payload'] is Map<String, dynamic>
          ? LedgerPayload.fromJson(
              json['ledger_payload'] as Map<String, dynamic>)
          : null,
      ideaPayload: json['idea_payload'] is Map<String, dynamic>
          ? IdeaPayload.fromJson(json['idea_payload'] as Map<String, dynamic>)
          : null,
      todoDeletePayload: json['todo_delete_payload'] is Map<String, dynamic>
          ? TodoDeletePayload.fromJson(
              json['todo_delete_payload'] as Map<String, dynamic>)
          : null,
      todoQueryPayload: json['todo_query_payload'] is Map<String, dynamic>
          ? TodoQueryPayload.fromJson(
              json['todo_query_payload'] as Map<String, dynamic>)
          : null,
      interactionMode: json['interaction_mode'] is String
          ? interactionModeFromJson(json['interaction_mode'] as String)
          : null,
      updatedFields: (json['updated_fields'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
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
      'todo_payloads':
          todoPayloads.map((todo) => todo.toJson()).toList(growable: false),
      'ledger_payload': ledgerPayload?.toJson(),
      'idea_payload': ideaPayload?.toJson(),
      'todo_delete_payload': todoDeletePayload?.toJson(),
      'todo_query_payload': todoQueryPayload?.toJson(),
      if (interactionMode != null) 'interaction_mode': interactionMode!.name,
      'updated_fields': updatedFields,
    };
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value)?.toLocal();
}
